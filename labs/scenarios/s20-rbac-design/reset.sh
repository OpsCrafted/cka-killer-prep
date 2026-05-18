#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
kubectl delete namespace rbac-test 2>/dev/null || true
echo "✓ Scenario reset"
