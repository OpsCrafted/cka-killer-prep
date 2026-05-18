#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
TAINTED=$(kubectl get nodes -o json | jq '[.items[] | select(.spec.taints[] | select(.key == "cni-pending"))] | length')
[[ $TAINTED -eq 0 ]] || { echo "✗ FAILED: CNI pending taint still present"; exit 1; }
echo "✓ PASSED: CNI migration complete"
exit 0
