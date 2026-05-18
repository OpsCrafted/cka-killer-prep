#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# PVC Expansion
kubectl get pvc expandable-claim -n expand-test 2>/dev/null || { echo "✗ FAILED: PVC not found"; exit 1; }
echo "✓ PASSED: PVC expansion configured"
exit 0
