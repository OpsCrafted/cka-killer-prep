#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done
kubectl taint nodes $(kubectl get nodes -o name | head -1) runtime=mismatch:NoSchedule 2>/dev/null || true
echo "✓ Scenario setup complete: runtime mismatch taint applied"
