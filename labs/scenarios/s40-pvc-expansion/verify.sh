#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: PVC exists
PVC_NAME="expandable-claim"
NAMESPACE="expand-test"
kubectl get pvc "$PVC_NAME" -n "$NAMESPACE" &>/dev/null || {
  echo "✗ FAILED: PVC $PVC_NAME not found in namespace $NAMESPACE"
  exit 1
}

# Check 2: PVC status is Bound
status=$(kubectl get pvc "$PVC_NAME" -n "$NAMESPACE" -o jsonpath='{.status.phase}')
if [[ "$status" != "Bound" ]]; then
  echo "✗ FAILED: PVC not bound (status: $status)"
  exit 1
fi

# Check 3: PVC has expanded (check current capacity > original 1Gi)
current_capacity=$(kubectl get pvc "$PVC_NAME" -n "$NAMESPACE" -o jsonpath='{.status.capacity.storage}')
# Check if it's > 1Gi (should be 2Gi or 5Gi after expansion)
if [[ "$current_capacity" == "1Gi" ]]; then
  echo "✗ FAILED: PVC not expanded (still 1Gi)"
  exit 1
fi

# Check 4: StorageClass allows expansion
sc_name=$(kubectl get pvc "$PVC_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.storageClassName}')
allows_expand=$(kubectl get storageclass "$sc_name" -o jsonpath='{.allowVolumeExpansion}')
if [[ "$allows_expand" != "true" ]]; then
  echo "⚠ WARNING: StorageClass does not allow expansion"
fi

echo "✓ PASSED: PVC expanded successfully (capacity: $current_capacity)"
exit 0
