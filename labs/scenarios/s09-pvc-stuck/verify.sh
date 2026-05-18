#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check PVC is Bound
PVC_STATUS=$(kubectl get pvc data-pvc -o jsonpath='{.status.phase}' 2>/dev/null)

if [ "$PVC_STATUS" != "Bound" ]; then
  echo "✗ FAILED: PVC status is $PVC_STATUS (expected Bound)"
  exit 1
fi

# Check pod is Running
POD=$(kubectl get pods -l app=app-with-storage -o jsonpath='{.items[0].status.phase}' 2>/dev/null)

if [ "$POD" != "Running" ]; then
  echo "✗ FAILED: Pod status is $POD (expected Running)"
  exit 1
fi

echo "✓ PASSED: PVC Bound and pod running"
exit 0
