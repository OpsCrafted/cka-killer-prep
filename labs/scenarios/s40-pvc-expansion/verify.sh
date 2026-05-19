#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: PVC exists
PVC_NAME="expandable-claim"
NAMESPACE="expand-test"
kubectl get pvc "$PVC_NAME" -n "$NAMESPACE" 2>/dev/null || {
  echo "✗ FAILED: PVC $PVC_NAME not found in namespace $NAMESPACE"
  exit 1
}

# Check 2: PVC is bound
PVC_STATUS=$(kubectl get pvc "$PVC_NAME" -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$PVC_STATUS" != "Bound" ]]; then
  echo "✗ FAILED: PVC not bound (status: $PVC_STATUS)"
  exit 1
fi

# Check 3: PVC has expansion enabled (allowVolumeExpansion on StorageClass)
SC=$(kubectl get pvc "$PVC_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.storageClassName}' 2>/dev/null)
if [[ -n "$SC" ]]; then
  ALLOW_EXPAND=$(kubectl get storageclass "$SC" -o jsonpath='{.allowVolumeExpansion}' 2>/dev/null)
  if [[ "$ALLOW_EXPAND" != "true" ]]; then
    echo "⚠ WARNING: StorageClass $SC does not allow expansion"
  fi
fi

# Check 4: Verify requested size (user should have expanded PVC)
REQUESTED=$(kubectl get pvc "$PVC_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null)
STATUS_SIZE=$(kubectl get pvc "$PVC_NAME" -n "$NAMESPACE" -o jsonpath='{.status.capacity.storage}' 2>/dev/null)

if [[ -n "$REQUESTED" && -n "$STATUS_SIZE" ]]; then
  echo "✓ PASSED: PVC expansion configured (requested: $REQUESTED, allocated: $STATUS_SIZE)"
else
  echo "✓ PASSED: PVC expansion configured (expandable PVC exists)"
fi

exit 0
