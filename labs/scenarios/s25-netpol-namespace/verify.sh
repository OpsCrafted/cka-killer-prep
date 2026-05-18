#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Network Policy
kubectl get networkpolicy deny-all -n netpol-test 2>/dev/null || { echo "✗ FAILED: NetworkPolicy not found"; exit 1; }
echo "✓ PASSED: NetworkPolicy configured"
exit 0
