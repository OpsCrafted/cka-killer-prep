#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Local Storage
kubectl get storageclass local 2>/dev/null || { echo "✗ FAILED: StorageClass not found"; exit 1; }
echo "✓ PASSED: Local storage configured"
exit 0
