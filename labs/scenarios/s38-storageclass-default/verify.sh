#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check StorageClass exists
kubectl get storageclass cka-default 2>/dev/null || { echo "✗ FAILED: StorageClass cka-default not found"; exit 1; }

# Check it's marked as default
DEFAULT=$(kubectl get storageclass cka-default -o jsonpath='{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}' 2>/dev/null)
if [[ "$DEFAULT" != "true" ]]; then
  echo "✗ FAILED: StorageClass not marked as default"
  exit 1
fi

echo "✓ PASSED: Default StorageClass configured"
exit 0
