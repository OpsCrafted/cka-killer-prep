#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"

export KUBECONFIG

# Check 1: At least one node has worker label
WORKERS=$(kubectl get nodes -l node-role.kubernetes.io/worker -o jsonpath='{.items[*].metadata.name}' | wc -w)
if [[ $WORKERS -lt 1 ]]; then
  echo "✗ FAILED: No nodes with worker label"
  exit 1
fi

# Check 2: Node is Ready
if ! kubectl get nodes -l node-role.kubernetes.io/worker | grep -q "Ready"; then
  echo "✗ FAILED: Worker node not Ready"
  exit 1
fi

echo "✓ PASSED: Node properly joined and labeled"
echo "  - Found $WORKERS worker node(s)"
echo "  - Worker node is Ready"
exit 0
