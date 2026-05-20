#!/usr/bin/env bash
# Random CKA exam simulator — 8 random scenarios, timed, scored by domain
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="${SCRIPT_DIR}/.state"
CLUSTER_NAME="cka-lab"
KUBECONFIG="${STATE_DIR}/kubeconfig"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}→${NC} $1"; }
log_ok() { echo -e "${GREEN}✓${NC} $1"; }
log_err() { echo -e "${RED}✗${NC} $1"; }
log_warn() { echo -e "${YELLOW}!${NC} $1"; }

check_deps() {
  for cmd in docker kind kubectl jq; do
    if ! command -v "$cmd" &>/dev/null; then
      log_err "Missing: $cmd"
      return 1
    fi
  done
  # shuf is optional; sort -R fallback used if unavailable
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
  local scenario_dir=$(ls -d "${SCRIPT_DIR}/scenarios/s${scenario_id}-"* 2>/dev/null | head -1)

  if [[ -z "$scenario_dir" ]]; then
    log_err "Scenario s${scenario_id} not found"
    return 1
  fi

  local name=$(basename "$scenario_dir" | sed 's/s[0-9]*-//')
  local domain=$(get_scenario_domain "$scenario_dir")
  echo -e "\n${BLUE}[Exam] s${scenario_id}: ${name} (${domain})${NC}"

  if [[ ! -f "${scenario_dir}/setup.sh" ]]; then
    log_err "No setup.sh"
    return 1
  fi

  export KUBECONFIG
  if ! bash "${scenario_dir}/setup.sh" "$CLUSTER_NAME" "$KUBECONFIG" &>/dev/null; then
    log_err "Setup failed"
    return 1
  fi

  if [[ ! -f "${scenario_dir}/verify.sh" ]]; then
    log_err "No verify.sh"
    return 1
  fi

  if bash "${scenario_dir}/verify.sh" "$CLUSTER_NAME" "$KUBECONFIG" &>/dev/null; then
    log_err "Scenario not broken (verify passed on setup)"
    return 1
  else
    log_ok "Scenario ready (broken state verified)"
    return 0
  fi
}

pick_random_scenarios() {
  local count=8
  local all_scenarios=()

  # Collect all valid scenario numbers (skip design labs)
  for scenario_dir in "${SCRIPT_DIR}"/scenarios/s*; do
    if [[ -d "$scenario_dir" && -f "${scenario_dir}/setup.sh" && -f "${scenario_dir}/verify.sh" ]]; then
      local status=$(grep "^status:" "${scenario_dir}/meta.yaml" 2>/dev/null | awk '{print $2}')
      # Skip design labs (conceptual, not executable)
      if [[ "$status" == "design" ]]; then
        continue
      fi
      local num=$(basename "$scenario_dir" | sed 's/^s0*//' | sed 's/-.*//')
      all_scenarios+=("$num")
    fi
  done

  # Shuffle and pick first N
  if [[ ${#all_scenarios[@]} -lt $count ]]; then
    log_warn "Only ${#all_scenarios[@]} scenarios available, need $count"
    count=${#all_scenarios[@]}
  fi

  # Use shuf to randomize (fallback to awk for BSD-safe shuffle)
  local shuffled
  if command -v shuf &>/dev/null; then
    shuffled=$(printf '%s\n' "${all_scenarios[@]}" | shuf | head -n $count)
  else
    # BSD-safe shuffle using awk (works on macOS)
    shuffled=$(printf '%s\n' "${all_scenarios[@]}" | awk 'BEGIN{srand()} {print rand(), $0}' | sort -n | cut -d' ' -f2 | head -n $count)
  fi

  echo "$shuffled"
}

main() {
  check_deps || exit 1

  log_info "Initializing exam environment..."
  init_cluster || exit 1
  wait_cluster_ready || exit 1

  log_info "Selecting 8 random scenarios..."
  local selected_scenarios=$(pick_random_scenarios)

  local passed=0
  local failed=0
  local exam_start=$(date +%s)
  local domain_results=""
  local exam_scenarios=""

  echo -e "\n${BLUE}════════════════════════════════════════${NC}"
  echo -e "${BLUE}CKA Random Exam — 8 Scenarios${NC}"
  echo -e "${BLUE}════════════════════════════════════════${NC}"

  local scenario_num=1
  while IFS= read -r scenario_id; do
    [[ -z "$scenario_id" ]] && continue

    echo -e "\n${BLUE}[${scenario_num}/8]${NC}"

    local scenario_dir=$(ls -d "${SCRIPT_DIR}/scenarios/s${scenario_id}-"* 2>/dev/null | head -1)
    local domain=$(get_scenario_domain "$scenario_dir")
    local difficulty=$(get_scenario_difficulty "$scenario_dir")
    local name=$(basename "$scenario_dir" | sed 's/s[0-9]*-//')

    local scenario_start=$(date +%s)

    if test_scenario "$scenario_id"; then
      ((passed++))
      local status="passed"
    else
      ((failed++))
      local status="failed"
    fi

    local scenario_end=$(date +%s)
    local elapsed=$((scenario_end - scenario_start))

    exam_scenarios+=$'|\n'"$scenario_id|$name|$domain|$difficulty|$status|$elapsed"$'\n'

    # Track by domain (bash 3.2 compatible string format)
    domain_results+=$'\n'"$domain|$status"

    if [[ -f "${scenario_dir}/reset.sh" ]]; then
      bash "${scenario_dir}/reset.sh" "$CLUSTER_NAME" "$KUBECONFIG" &>/dev/null || true
    fi

    ((scenario_num++))
  done <<< "$selected_scenarios"

  local exam_end=$(date +%s)
  local exam_elapsed=$((exam_end - exam_start))
  local exam_minutes=$((exam_elapsed / 60))
  local exam_seconds=$((exam_elapsed % 60))

  # Calculate scores by domain
  local total_by_domain=0
  local total_passed_by_domain=0

  echo -e "\n${BLUE}════════════════════════════════════════${NC}"
  echo -e "${BLUE}EXAM RESULTS${NC}"
  echo -e "${BLUE}════════════════════════════════════════${NC}"

  echo -e "\n${GREEN}Overall:${NC}"
  echo "  Result: $passed/8 passed"
  echo "  Time: ${exam_minutes}m ${exam_seconds}s"

  local percent=$((passed * 100 / 8))
  if [[ $percent -ge 70 ]]; then
    echo -e "  Score: ${GREEN}${percent}%${NC} ✓ PASS"
  elif [[ $percent -ge 50 ]]; then
    echo -e "  Score: ${YELLOW}${percent}%${NC} ! Review weak areas"
  else
    echo -e "  Score: ${RED}${percent}%${NC} ✗ FAIL - More practice needed"
  fi

  echo -e "\n${GREEN}By Domain:${NC}"
  for domain in $(echo "$domain_results" | grep -v '^$' | awk -F'|' '{print $1}' | sort -u); do
    local p_count=$(echo "$domain_results" | grep "^$domain|passed$" | wc -l)
    local f_count=$(echo "$domain_results" | grep "^$domain|failed$" | wc -l)
    local total=$((p_count + f_count))
    local d_percent=$((p_count * 100 / total))
    printf "  %-20s %d/%d (%d%%)\n" "$domain:" "$p_count" "$total" "$d_percent"
  done

  if [[ $failed -gt 0 ]]; then
    echo -e "\n${RED}Failed Scenarios:${NC}"
    echo "$exam_scenarios" | grep -v '^$' | while IFS='|' read -r blank id name domain diff status elapsed; do
      [[ "$status" == "failed" ]] && printf "  s%s (%s): %s\n" "$id" "$domain" "$name"
    done

    echo -e "\n${YELLOW}Retry:${NC}"
    echo "$exam_scenarios" | grep -v '^$' | while IFS='|' read -r blank id name domain diff status elapsed; do
      [[ "$status" == "failed" ]] && echo "  ./run.sh $id"
    done
  fi

  echo -e "\n${BLUE}════════════════════════════════════════${NC}"

  if [[ $percent -ge 70 ]]; then
    log_ok "Exam passed!"
    exit 0
  else
    log_err "Exam failed - retake or review weak domains"
    exit 1
  fi
}

main "$@"
