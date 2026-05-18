#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done
# CRD definition exists but not applied
echo "✓ Scenario setup complete: CRD needs to be applied"
