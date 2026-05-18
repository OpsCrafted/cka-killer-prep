#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
# Check if RBAC role is created
kubectl get role -n rbac-test 2>/dev/null | grep -q app-role || { echo "✗ FAILED: RBAC role not created"; exit 1; }
echo "✓ PASSED: RBAC policy configured"
exit 0
