#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# LoadBalancer Service
kubectl get service app-lb -n lb-test 2>/dev/null || { echo "✗ FAILED: Service not found"; exit 1; }
echo "✓ PASSED: LoadBalancer service created"
exit 0
