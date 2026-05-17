#!/bin/bash
set -euo pipefail

CLUSTER_NAME="${1:-cka-lab}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$SCRIPT_DIR/../kind-config.yaml"

echo "═══════════════════════════════════════════════"
echo "  CKA Killer Prep — Cluster Setup"
echo "═══════════════════════════════════════════════"

# Check prerequisites
for cmd in kind kubectl docker; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "ERROR: $cmd is required but not installed."
    echo "Install: brew install $cmd"
    exit 1
  fi
done

# Check if Docker is running
if ! docker info &> /dev/null 2>&1; then
  echo "ERROR: Docker is not running. Start Docker Desktop first."
  exit 1
fi

# Delete existing cluster if it exists
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
  echo "Cluster '$CLUSTER_NAME' exists. Deleting..."
  kind delete cluster --name "$CLUSTER_NAME"
fi

# Create cluster
echo "Creating cluster '$CLUSTER_NAME' (1 control-plane + 2 workers)..."
kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG"

# Verify
echo ""
echo "Cluster nodes:"
kubectl get nodes -o wide
echo ""
echo "═══════════════════════════════════════════════"
echo "  ✅ Cluster '$CLUSTER_NAME' is ready"
echo "  Context: kind-$CLUSTER_NAME"
echo "═══════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "  ./labs/scripts/break.sh <lab-name>    # break something"
echo "  ./labs/scripts/verify.sh <lab-name>   # check your fix"
echo "  ./labs/scripts/reset.sh               # reset cluster"
