#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Service Discovery
kubectl get service app -n svc-test 2>/dev/null || { echo "✗ FAILED: Service not found"; exit 1; }
echo "✓ PASSED: Service discovery configured"
exit 0
