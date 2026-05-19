#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: Local StorageClass exists
kubectl get storageclass local 2>/dev/null || {
  echo "✗ FAILED: Local StorageClass not found"
  exit 1
}

# Check 2: StorageClass has volumeBindingMode (local volumes need Immediate or WaitForFirstConsumer)
BINDING=$(kubectl get storageclass local -o jsonpath='{.volumeBindingMode}' 2>/dev/null)
if [[ -z "$BINDING" ]]; then
  echo "✗ FAILED: StorageClass missing volumeBindingMode"
  exit 1
fi

# Check 3: Verify provisioner is configured for local storage
PROVISIONER=$(kubectl get storageclass local -o jsonpath='{.provisioner}' 2>/dev/null)
if [[ -z "$PROVISIONER" ]]; then
  echo "✗ FAILED: Local StorageClass has no provisioner"
  exit 1
fi

echo "✓ PASSED: Local storage StorageClass configured (provisioner: $PROVISIONER, binding: $BINDING)"
exit 0
