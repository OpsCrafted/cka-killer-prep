#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# HPA
kubectl get hpa app-hpa -n hpa-test 2>/dev/null || { echo "✗ FAILED: HPA not found"; exit 1; }
echo "✓ PASSED: HPA configured"
exit 0
