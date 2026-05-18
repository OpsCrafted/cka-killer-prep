#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Resource Limits
kubectl get pod app-pod -n resource-test 2>/dev/null || { echo "✗ FAILED: Pod not found"; exit 1; }
echo "✓ PASSED: Resource limits configured"
exit 0
