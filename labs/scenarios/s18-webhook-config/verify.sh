#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
# Check if webhook is deleted/fixed
kubectl get mutatingwebhookconfigurations broken-webhook &>/dev/null && { echo "✗ FAILED: Broken webhook still exists"; exit 1; }
echo "✓ PASSED: Webhook configuration fixed"
exit 0
