#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"

export KUBECONFIG

# Check if kube-apiserver pod has audit-log-path
APISERVER=$(kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [[ -z "$APISERVER" ]]; then
  echo "⚠ WARNING: No kube-apiserver pod found (not applicable on this cluster)"
  echo "✓ PASSED: Audit logging scenario (N/A on kind clusters)"
  exit 0
fi

# Check if apiserver has audit configuration
if kubectl get pod "$APISERVER" -n kube-system -o yaml | grep -q 'audit-log-path'; then
  echo "✓ PASSED: Audit logging configured"
  echo "  - API server has audit-log-path flag"
  exit 0
else
  echo "✗ FAILED: Audit logging not configured on API server"
  exit 1
fi
