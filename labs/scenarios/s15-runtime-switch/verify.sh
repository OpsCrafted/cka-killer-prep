#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
TAINTED=$(kubectl get nodes -o json | jq '[.items[] | select(.spec.taints[] | select(.key == "runtime"))] | length')
[[ $TAINTED -eq 0 ]] || { echo "✗ FAILED: Runtime mismatch taint still present"; exit 1; }
echo "✓ PASSED: Runtime configured correctly"
exit 0
