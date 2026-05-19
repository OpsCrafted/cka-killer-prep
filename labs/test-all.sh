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
  for cmd in docker kind kubectl; do
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
  declare -A domain_pass
  declare -A domain_fail

  echo -e "\n${BLUE}════════════════════════════════════════${NC}"
  echo -e "${BLUE}Testing Scenarios 01-40 (mode: $mode)${NC}"
  echo -e "${BLUE}════════════════════════════════════════${NC}"

  for i in $(seq -f '%02g' 1 40); do
    scenario_dir=$(ls -d "${SCRIPT_DIR}/scenarios/s${i}-"* 2>/dev/null | head -1)
    domain=$(get_scenario_domain "$scenario_dir")

    if test_scenario "$i" "$mode"; then
      ((passed++))
      ((domain_pass[$domain]++))
    else
      ((failed++))
      ((domain_fail[$domain]++))
    fi

    if [[ -f "${scenario_dir}/reset.sh" ]]; then
      bash "${scenario_dir}/reset.sh" "$CLUSTER_NAME" "$KUBECONFIG" &>/dev/null || true
    fi
  done

  local end_time=$(date +%s)
  local elapsed=$((end_time - start_time))
  local minutes=$((elapsed / 60))
  local seconds=$((elapsed % 60))

  echo -e "\n${BLUE}════════════════════════════════════════${NC}"
  echo -e "Results: ${GREEN}${passed} passed${NC}, ${RED}${failed} failed${NC}"
  echo -e "Time: ${minutes}m ${seconds}s"
  echo -e "${BLUE}════════════════════════════════════════${NC}"

  if [[ ${#domain_fail[@]} -gt 0 ]]; then
    echo -e "\n${RED}Domains Needing Work:${NC}"
    for domain in "${!domain_fail[@]}"; do
      pass=${domain_pass[$domain]:-0}
      fail=${domain_fail[$domain]}
      total=$((pass + fail))
      echo -e "  ${RED}✗${NC} $domain: $fail/$total failed"
    done
  fi

  if [[ $failed -eq 0 ]]; then
    log_ok "All tests passed"
    exit 0
  else
    log_err "$failed test(s) failed"
    exit 1
  fi
}

main "$@"
