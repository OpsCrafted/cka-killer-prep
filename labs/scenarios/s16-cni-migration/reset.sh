#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
kubectl delete daemonset -n kube-system wait-for-cni 2>/dev/null || true
kubectl taint nodes --all cni-pending- 2>/dev/null || true
echo "✓ Scenario reset"
