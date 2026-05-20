#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="${SCRIPT_DIR}/.state"
CLUSTER_NAME="cka-lab"
KUBECONFIG="${STATE_DIR}/kubeconfig"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}→${NC} $1"; }
log_ok() { echo -e "${GREEN}✓${NC} $1"; }
log_err() { echo -e "${RED}✗${NC} $1"; }

check_deps() {
  for cmd in docker kind kubectl jq; do
    if ! command -v "$cmd" &>/dev/null; then
      log_err "Missing: $cmd"
      return 1
    fi
  done
  return 0
}

init_cluster() {
  mkdir -p "$STATE_DIR"

  if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
    log_ok "Cluster running"
    kind get kubeconfig --name "$CLUSTER_NAME" > "$KUBECONFIG" 2>/dev/null
    return 0
  fi

  log_info "Creating kind cluster..."
  if kind create cluster \
    --name "$CLUSTER_NAME" \
    --config "$SCRIPT_DIR/kind-config.yaml" \
    --kubeconfig "$KUBECONFIG" 2>/dev/null; then
    log_ok "Cluster created"
    return 0
  fi

  log_info "Falling back to existing 'kind' cluster..."
  if kind get clusters 2>/dev/null | grep -q "^kind$"; then
    CLUSTER_NAME="kind"
    kind get kubeconfig --name kind > "$KUBECONFIG" 2>/dev/null
    log_ok "Using existing cluster"
    return 0
  fi

  log_err "No cluster available"
  return 1
}

wait_cluster_ready() {
  local timeout=60
  local elapsed=0

  log_info "Waiting for cluster..."
  export KUBECONFIG

  while [[ $elapsed -lt $timeout ]]; do
    if kubectl get nodes -o json 2>/dev/null | jq -e '.items | length > 0' &>/dev/null; then
      log_ok "Cluster ready"
      return 0
    fi
    sleep 2
    elapsed=$((elapsed + 2))
  done

  log_err "Cluster timeout"
  return 1
}

get_scenario_domain() {
  local scenario_dir="$1"
  if [[ -f "${scenario_dir}/meta.yaml" ]]; then
    grep "^domain:" "${scenario_dir}/meta.yaml" | awk '{print $2}'
  else
    echo "unknown"
  fi
}

get_scenario_difficulty() {
  local scenario_dir="$1"
  if [[ -f "${scenario_dir}/meta.yaml" ]]; then
    grep "^difficulty:" "${scenario_dir}/meta.yaml" | awk '{print $2}'
  else
    echo "unknown"
  fi
}

test_scenario() {
  local scenario_id="$1"
  local mode="${2:-setup}"
  local scenario_dir=$(ls -d "${SCRIPT_DIR}/scenarios/s${scenario_id}-"* 2>/dev/null | head -1)

  if [[ -z "$scenario_dir" ]]; then
    log_err "Scenario s${scenario_id} not found"
    return 1
  fi

  local name=$(basename "$scenario_dir" | sed 's/s[0-9]*-//')
  local domain=$(get_scenario_domain "$scenario_dir")
  echo -e "\n${BLUE}Testing s${scenario_id}: ${name} (${domain})${NC}"

  if [[ ! -f "${scenario_dir}/setup.sh" ]]; then
    log_err "No setup.sh"
    return 1
  fi

  export KUBECONFIG
  if ! bash "${scenario_dir}/setup.sh" "$CLUSTER_NAME" "$KUBECONFIG" &>/dev/null; then
    log_err "Setup failed"
    return 1
  fi

  log_ok "Setup complete"

  # If contract mode, verify that verify.sh fails on broken state (proving contract holds)
  if [[ "$mode" == "contract" ]]; then
    if [[ ! -f "${scenario_dir}/verify.sh" ]]; then
      log_err "No verify.sh"
      return 1
    fi
    if bash "${scenario_dir}/verify.sh" "$CLUSTER_NAME" "$KUBECONFIG" &>/dev/null; then
      log_err "Contract broken: verify.sh should fail on broken state"
      return 1
    else
      log_ok "Contract verified (verify detects broken state)"
      return 0
    fi
  fi

  return 0
}

generate_json_report() {
  local mode="$1"
  local passed="$2"
  local failed="$3"
  local elapsed="$4"
  local scenarios_json="$5"
  local domains_json="$6"

  local iso_timestamp=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

  cat > "${STATE_DIR}/report.json" <<EOF
{
  "generated_at": "$iso_timestamp",
  "mode": "$mode",
  "summary": {
    "passed": $passed,
    "failed": $failed,
    "total": $((passed + failed)),
    "elapsed_seconds": $elapsed
  },
  "domains": $domains_json,
  "scenarios": $scenarios_json
}
EOF
}

generate_markdown_report() {
  local json_file="${STATE_DIR}/report.json"

  if [[ ! -f "$json_file" ]]; then
    return
  fi

  local mode=$(jq -r '.mode' "$json_file")
  local passed=$(jq -r '.summary.passed' "$json_file")
  local failed=$(jq -r '.summary.failed' "$json_file")
  local total=$(jq -r '.summary.total' "$json_file")
  local elapsed=$(jq -r '.summary.elapsed_seconds' "$json_file")
  local minutes=$((elapsed / 60))
  local seconds=$((elapsed % 60))

  local failed_count=$(jq '[.scenarios[] | select(.status == "failed")] | length' "$json_file")
  local failed_list=$(jq -r '.scenarios[] | select(.status == "failed") | "- **s\(.id)** (\(.domain)): \(.name)"' "$json_file" | sed 's/^/  /')

  local weak_domains=$(jq -r '.domains | to_entries | .[] | select(.value.failed > 0) | "- **\(.key)**: \(.value.passed)/\(.value.total)"' "$json_file" | sed 's/^/  /')

  local retry_cmds=$(jq -r '.scenarios[] | select(.status == "failed") | "./run.sh \(.id)"' "$json_file" | sed 's/^/  /')

  cat > "${STATE_DIR}/report.md" <<EOF
# CKA Lab Report

**Mode:** $mode
**Result:** $passed/$total passed
**Time:** ${minutes}m ${seconds}s

---

## Summary

✓ Passed: $passed
✗ Failed: $failed

EOF

  if [[ $failed_count -gt 0 ]]; then
    cat >> "${STATE_DIR}/report.md" <<EOF
## Failed Scenarios

$failed_list

EOF
  fi

  if [[ -n "$weak_domains" ]]; then
    cat >> "${STATE_DIR}/report.md" <<EOF
## Weak Domains

$weak_domains

EOF
  fi

  if [[ $failed_count -gt 0 ]]; then
    cat >> "${STATE_DIR}/report.md" <<EOF
## Retry Commands

\`\`\`bash
$retry_cmds
\`\`\`

EOF
  fi

  cat >> "${STATE_DIR}/report.md" <<EOF
---

Run all: \`bash test-all.sh $mode\`
EOF
}

main() {
  local mode="${1:-setup}"

  if [[ "$mode" != "setup" && "$mode" != "contract" ]]; then
    echo "Usage: $0 [setup|contract]"
    echo "  setup:    run setup.sh only (default) — verifies setup introduces failure"
    echo "  contract: run setup.sh then verify.sh — verifies verify detects broken state"
    exit 1
  fi

  check_deps || exit 1

  log_info "Initializing test environment..."
  init_cluster || exit 1
  wait_cluster_ready || exit 1

  local passed=0
  local failed=0
  local start_time=$(date +%s)
  local failed_scenarios=""
  local scenarios_data=""

  echo -e "\n${BLUE}════════════════════════════════════════${NC}"
  echo -e "${BLUE}Testing Scenarios 01-40 (mode: $mode)${NC}"
  echo -e "${BLUE}════════════════════════════════════════${NC}"

  for i in $(seq -f '%02g' 1 40); do
    scenario_dir=$(ls -d "${SCRIPT_DIR}/scenarios/s${i}-"* 2>/dev/null | head -1)
    scenario_status=$(grep "^status:" "$scenario_dir/meta.yaml" 2>/dev/null | awk '{print $2}')

    # Skip design scenarios (conceptual labs, not executable)
    if [[ "$scenario_status" == "design" ]]; then
      continue
    fi

    domain=$(get_scenario_domain "$scenario_dir")
    difficulty=$(get_scenario_difficulty "$scenario_dir")
    name=$(basename "$scenario_dir" | sed 's/s[0-9]*-//')

    local scenario_start=$(date +%s%N)

    if test_scenario "$i" "$mode"; then
      ((passed++))
      local status="passed"
    else
      ((failed++))
      local status="failed"
      failed_scenarios="$failed_scenarios
  s$i ($domain)"
    fi

    local scenario_end=$(date +%s%N)
    local elapsed_ms=$(( (scenario_end - scenario_start) / 1000000 ))
    local elapsed_sec=$(( elapsed_ms / 1000 ))

    # Track per-scenario data
    scenarios_data+=$'{\n'
    scenarios_data+="\"id\": \"$i\", \"name\": \"$name\", \"domain\": \"$domain\", \"difficulty\": \"$difficulty\", \"status\": \"$status\", \"elapsed_seconds\": $elapsed_sec"$'\n'
    scenarios_data+=$'}\n'

    if [[ -f "${scenario_dir}/reset.sh" ]]; then
      bash "${scenario_dir}/reset.sh" "$CLUSTER_NAME" "$KUBECONFIG" &>/dev/null || true
    fi
  done

  local end_time=$(date +%s)
  local elapsed=$((end_time - start_time))
  local minutes=$((elapsed / 60))
  local seconds=$((elapsed % 60))

  # Build JSON structures (bash 3.2 compatible - no arrays/associative arrays)
  local scenarios_json="[$(echo "$scenarios_data" | grep -v '^$')]"

  # Calculate domain stats from scenarios_data
  local domains_json="{"
  local first=true
  for domain in $(echo "$scenarios_data" | grep '"domain"' | sed 's/.*"domain": "\([^"]*\)".*/\1/' | sort -u); do
    local p_count=$(echo "$scenarios_data" | grep "\"domain\": \"$domain\"" | grep '"status": "passed"' | wc -l)
    local f_count=$(echo "$scenarios_data" | grep "\"domain\": \"$domain\"" | grep '"status": "failed"' | wc -l)
    if [[ "$first" == false ]]; then
      domains_json+=","
    fi
    domains_json+="\"$domain\": {\"passed\": $p_count, \"failed\": $f_count, \"total\": $((p_count + f_count))}"
    first=false
  done
  domains_json+="}"

  # Generate reports
  generate_json_report "$mode" "$passed" "$failed" "$elapsed" "$scenarios_json" "$domains_json"
  generate_markdown_report

  echo -e "\n${BLUE}════════════════════════════════════════${NC}"
  echo -e "Results: ${GREEN}${passed} passed${NC}, ${RED}${failed} failed${NC}"
  echo -e "Time: ${minutes}m ${seconds}s"
  echo -e "${BLUE}════════════════════════════════════════${NC}"

  if [[ -n "$failed_scenarios" ]]; then
    echo -e "\n${RED}Failed Scenarios:${NC}$failed_scenarios"
  fi

  log_info "Report: ${STATE_DIR}/report.md"

  if [[ $failed -eq 0 ]]; then
    log_ok "All tests passed"
    exit 0
  else
    log_err "$failed test(s) failed"
    exit 1
  fi
}

main "$@"
