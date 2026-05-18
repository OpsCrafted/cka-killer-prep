#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# DNS Service
kubectl get service test-svc -n dns-test 2>/dev/null || { echo "✗ FAILED: Service not found"; exit 1; }
echo "✓ PASSED: DNS service configured"
exit 0
