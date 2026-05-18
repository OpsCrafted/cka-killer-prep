#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
kubectl delete mutatingwebhookconfigurations broken-webhook 2>/dev/null || true
echo "✓ Scenario reset"
