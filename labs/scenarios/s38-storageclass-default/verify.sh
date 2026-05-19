#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: StorageClass exists
kubectl get storageclass cka-default &>/dev/null || {
  echo "✗ FAILED: StorageClass cka-default not found"
  exit 1
}

# Check 2: StorageClass is marked as default
is_default=$(kubectl get storageclass cka-default -o jsonpath='{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}')
if [[ "$is_default" != "true" ]]; then
  echo "✗ FAILED: StorageClass is not marked as default"
  exit 1
fi

# Check 3: StorageClass has provisioner
provisioner=$(kubectl get storageclass cka-default -o jsonpath='{.provisioner}')
if [[ -z "$provisioner" ]]; then
  echo "✗ FAILED: StorageClass has no provisioner"
  exit 1
fi

echo "✓ PASSED: Default StorageClass configured"
exit 0
