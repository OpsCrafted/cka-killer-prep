#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# PriorityClass
kubectl get priorityclass high-priority 2>/dev/null || { echo "✗ FAILED: PriorityClass not found"; exit 1; }
echo "✓ PASSED: PriorityClass configured"
exit 0
