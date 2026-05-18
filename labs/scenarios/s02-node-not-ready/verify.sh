#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check all nodes Ready
node_count=$(kubectl get nodes | tail -n +2 | wc -l)
ready_count=$(kubectl get nodes | grep "Ready" | wc -l)

if [ "$node_count" -ne "$ready_count" ]; then
  echo "✗ FAILED: $ready_count/$node_count nodes Ready"
  kubectl get nodes
  exit 1
fi

echo "✓ PASSED: All nodes Ready"
exit 0
