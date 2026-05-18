#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check if critical-app namespace exists
if kubectl get namespace critical-app &>/dev/null; then
  echo "✓ PASSED: Namespace restored"
  exit 0
else
  echo "✗ FAILED: Namespace not found"
  exit 1
fi
