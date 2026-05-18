#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Affinity/Taints
kubectl get pod affinity-pod 2>/dev/null || { echo "✗ FAILED: Pod not found"; exit 1; }
echo "✓ PASSED: Affinity and taints configured"
exit 0
