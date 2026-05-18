#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# StatefulSet
kubectl get statefulset db -n stateful-test 2>/dev/null || { echo "✗ FAILED: StatefulSet not found"; exit 1; }
echo "✓ PASSED: StatefulSet configured"
exit 0
