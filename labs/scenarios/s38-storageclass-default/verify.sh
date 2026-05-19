#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: StorageClass exists
kubectl get storageclass cka-default 2>/dev/null || {
  echo "✗ FAILED: StorageClass cka-default not found"
  exit 1
}

# Check 2: StorageClass is marked as default
DEFAULT=$(kubectl get storageclass cka-default -o jsonpath='{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}' 2>/dev/null)
if [[ "$DEFAULT" != "true" ]]; then
  echo "✗ FAILED: StorageClass not marked as default (current: $DEFAULT)"
  exit 1
fi

# Check 3: StorageClass has provisioner configured
PROVISIONER=$(kubectl get storageclass cka-default -o jsonpath='{.provisioner}' 2>/dev/null)
if [[ -z "$PROVISIONER" ]]; then
  echo "✗ FAILED: StorageClass has no provisioner configured"
  exit 1
fi

echo "✓ PASSED: Default StorageClass configured (provisioner: $PROVISIONER)"
exit 0
