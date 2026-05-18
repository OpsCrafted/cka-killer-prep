#!/usr/bin/env bash
set -euo pipefail

# CKA Killer Prep — Lab Runner (cross-platform)
# Usage: ./run.sh 01
# Works: Linux, macOS, Windows (Git Bash / WSL)

SCENARIO_ID="${1:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
STATE_DIR="${SCRIPT_DIR}/.state"
CLUSTER_NAME="cka-lab"
KUBECONFIG="${STATE_DIR}/kubeconfig"

# Color output (cross-platform)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}→${NC} $1"; }
log_ok() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_err() { echo -e "${RED}✗${NC} $1"; }

usage() {
  cat <<EOF
CKA Killer Prep — Lab Runner

Usage:
  ./run.sh <scenario-id>        Build and start lab
  ./run.sh list                 Show all scenarios
  ./run.sh clean                Delete cluster + state
  ./run.sh verify <scenario-id> Check if scenario solved

Examples:
  ./run.sh 01                   Start API server troubleshooting
  ./run.sh 15                   Start runtime switch lab
  ./run.sh verify 01            Check if fix passes

Requirements:
  - Docker (or Podman)
  - kind
  - kubectl
  - Git Bash / WSL (Windows only)

EOF
  exit 1
}

validate_scenario_id() {
  if ! [[ "$1" =~ ^[0-9]{2}$ ]]; then
    log_err "Scenario ID must be 2 digits (01-40)"
    exit 1
  fi
  if [[ "$1" -lt 1 || "$1" -gt 40 ]]; then
    log_err "Scenario must be 01-40"
    exit 1
  fi
}

check_deps() {
  local missing=0

  for cmd in docker kind kubectl; do
    if ! command -v "$cmd" &>/dev/null; then
      log_err "Missing: $cmd"
      missing=1
    fi
  done

  if [[ $missing -eq 1 ]]; then
    cat <<EOF
${RED}Missing dependencies.${NC} Install:

macOS:
  brew install docker kind kubectl

Linux (Ubuntu/Debian):
  curl -fsSL https://get.docker.com | sh
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
  chmod +x ./kind && sudo mv ./kind /usr/local/bin/

Windows (Git Bash / WSL):
  Install Docker Desktop, then:
  choco install kind kubectl

EOF
    exit 1
  fi
}

init_state() {
  mkdir -p "$STATE_DIR"
  touch "$STATE_DIR/scenarios.log"
}

ensure_cluster() {
  if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
    log_ok "Cluster running"
    return 0
  fi

  log_info "Creating kind cluster..."
  kind create cluster \
    --name "$CLUSTER_NAME" \
    --config "$SCRIPT_DIR/kind-config.yaml" \
    --kubeconfig "$KUBECONFIG" 2>/dev/null || true

  log_ok "Cluster created"
}

list_scenarios() {
  cat <<EOF
${BLUE}CKA Scenarios — 40 Total${NC}

${BLUE}TROUBLESHOOTING (30% weight — 12 scenarios)${NC}
  01 - api-server-down          Control plane API crashed
  02 - node-not-ready           Worker node kernel panic
  03 - coredns-broken           Cluster DNS failure
  04 - service-no-endpoints     Service has no pods
  05 - pod-crashloop            Missing startup config
  06 - scheduler-unresponsive   Pods stuck pending
  07 - cert-expired             TLS validation failure
  08 - netpol-blocking          NetworkPolicy denying traffic
  09 - pvc-stuck                PersistentVolume won't bind
  10 - rbac-forbidden           ServiceAccount no permissions
  11 - etcd-corruption          Restore from backup
  12 - kubelet-misconfigured    Node can't reach API

${BLUE}CLUSTER ARCHITECTURE (25% weight — 10 scenarios)${NC}
  13 - cluster-upgrade          Rolling upgrade nodes
  14 - node-join                kubeadm bootstrap worker
  15 - runtime-switch           Replace container runtime
  16 - cni-migration            Swap network plugin
  17 - custom-api               CustomResourceDefinition setup
  18 - webhook-config           Mutating webhook interceptor
  19 - audit-logging            API server audit trail
  20 - rbac-design              RBAC for deployment
  21 - serviceaccount-binding   Cross-namespace access
  22 - backup-strategy          Full cluster backup/restore

${BLUE}SERVICES & NETWORKING (20% weight — 8 scenarios)${NC}
  23 - ingress-tls              HTTPS routing with certs
  24 - gateway-api              Gateway API + HTTPRoute
  25 - netpol-namespace         Namespace isolation
  26 - loadbalancer-expose      External LoadBalancer
  27 - dns-debugging            Broken DNS in pods
  28 - service-discovery        Endpoints not registering
  29 - gatewayclass-binding     Controller acknowledgment
  30 - multi-tenancy            Ingress across namespaces

${BLUE}WORKLOADS & SCHEDULING (15% weight — 6 scenarios)${NC}
  31 - deployment-rolling       Blue-green updates
  32 - statefulset-storage      Persistent pod identity
  33 - resource-limits          CPU/memory enforcement
  34 - affinity-taints          Schedule to specific nodes
  35 - priority-preemption      Critical workload priority
  36 - hpa-scaling              Auto-scale on metrics

${BLUE}STORAGE (10% weight — 4 scenarios)${NC}
  37 - pv-pvc-binding           Dynamic provisioning
  38 - storageclass-default     StorageClass creation
  39 - local-storage            Local path provisioning
  40 - pvc-expansion            Grow PersistentVolume

EOF
}

build_scenario() {
  local scenario_id="$1"
  local scenario_dir="${SCRIPT_DIR}/scenarios/s${scenario_id}-"*

  # Expand glob
  scenario_dir=$(ls -d "${SCRIPT_DIR}/scenarios/s${scenario_id}-"* 2>/dev/null | head -1)

  if [[ -z "$scenario_dir" ]]; then
    log_err "Scenario not found"
    exit 1
  fi

  log_info "Building scenario..."

  if [[ -f "${scenario_dir}/setup.sh" ]]; then
    bash "${scenario_dir}/setup.sh" "$CLUSTER_NAME" "$KUBECONFIG"
    log_ok "Built"
  fi
}

wait_cluster_ready() {
  local timeout=60
  local elapsed=0

  log_info "Waiting for cluster (${timeout}s)..."
  export KUBECONFIG

  while [[ $elapsed -lt $timeout ]]; do
    if kubectl get nodes -o json 2>/dev/null | jq -e '.items | length > 0' &>/dev/null; then
      log_ok "Ready"
      return 0
    fi
    sleep 2
    elapsed=$((elapsed + 2))
  done

  log_err "Cluster not ready"
  exit 1
}

run_scenario() {
  local scenario_id="$1"
  local scenario_dir="${SCRIPT_DIR}/scenarios/s${scenario_id}-"*
  scenario_dir=$(ls -d "${SCRIPT_DIR}/scenarios/s${scenario_id}-"* 2>/dev/null | head -1)

  export KUBECONFIG

  clear

  cat <<EOF
${BLUE}═══════════════════════════════════════════${NC}
${BLUE}  Scenario s${scenario_id}${NC}
${BLUE}═══════════════════════════════════════════${NC}

${YELLOW}📖 Task:${NC}
EOF

  if [[ -f "${scenario_dir}/TASK.md" ]]; then
    cat "${scenario_dir}/TASK.md"
  fi

  cat <<EOF

${YELLOW}🔧 Useful Commands:${NC}
  kubectl get nodes
  kubectl get pods -A
  kubectl describe node <name>
  kubectl logs <pod> -n <ns>

${YELLOW}✓ When Fixed:${NC}
  ../run.sh verify ${scenario_id}

${YELLOW}🔄 Reset:${NC}
  ../run.sh reset ${scenario_id}

${YELLOW}💡 Hints:${NC}
  cat ${scenario_dir}/HINTS.md

${BLUE}Press ENTER to start...${NC}
EOF

  read -r

  bash --init-file <(echo "
    export KUBECONFIG='$KUBECONFIG'
    export CLUSTER='$CLUSTER_NAME'
    alias k=kubectl
    alias kgn='kubectl get nodes'
    alias kgp='kubectl get pods -A'
    alias kg='kubectl get'

    echo '${GREEN}✓ Cluster ready${NC}'
  ") -i
}

verify_scenario() {
  local scenario_id="$1"
  local scenario_dir="${SCRIPT_DIR}/scenarios/s${scenario_id}-"*
  scenario_dir=$(ls -d "${SCRIPT_DIR}/scenarios/s${scenario_id}-"* 2>/dev/null | head -1)

  if [[ ! -f "${scenario_dir}/verify.sh" ]]; then
    log_err "No verify script"
    exit 1
  fi

  export KUBECONFIG

  log_info "Verifying..."

  if bash "${scenario_dir}/verify.sh" "$CLUSTER_NAME" "$KUBECONFIG"; then
    log_ok "PASSED ✓"
    echo "$scenario_id" >> "$STATE_DIR/scenarios.log"
    exit 0
  else
    log_err "FAILED ✗"
    exit 1
  fi
}

reset_scenario() {
  local scenario_id="$1"
  local scenario_dir="${SCRIPT_DIR}/scenarios/s${scenario_id}-"*
  scenario_dir=$(ls -d "${SCRIPT_DIR}/scenarios/s${scenario_id}-"* 2>/dev/null | head -1)

  if [[ ! -f "${scenario_dir}/reset.sh" ]]; then
    log_warn "No reset script"
    return 0
  fi

  export KUBECONFIG
  log_info "Resetting..."
  bash "${scenario_dir}/reset.sh" "$CLUSTER_NAME" "$KUBECONFIG"
  log_ok "Reset"
}

clean_all() {
  log_warn "Deleting cluster..."
  kind delete cluster --name "$CLUSTER_NAME" 2>/dev/null || true
  rm -rf "$STATE_DIR"
  log_ok "Cleaned"
}

main() {
  case "${SCENARIO_ID}" in
    ""|"-h"|"--help")
      usage
      ;;
    "list")
      list_scenarios
      ;;
    "clean")
      clean_all
      ;;
    "verify")
      if [[ -z "${2:-}" ]]; then
        log_err "Usage: ./run.sh verify <scenario-id>"
        exit 1
      fi
      validate_scenario_id "$2"
      check_deps
      init_state
      verify_scenario "$2"
      ;;
    "reset")
      if [[ -z "${2:-}" ]]; then
        log_err "Usage: ./run.sh reset <scenario-id>"
        exit 1
      fi
      validate_scenario_id "$2"
      check_deps
      init_state
      reset_scenario "$2"
      ;;
    *)
      validate_scenario_id "$SCENARIO_ID"
      check_deps
      init_state
      ensure_cluster
      build_scenario "$SCENARIO_ID"
      wait_cluster_ready
      run_scenario "$SCENARIO_ID"
      ;;
  esac
}

main "$@"
