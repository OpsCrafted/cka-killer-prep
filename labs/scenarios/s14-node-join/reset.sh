#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"

export KUBECONFIG

# Re-label all nodes as workers
for node in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
  kubectl label node "$node" node-role.kubernetes.io/worker=true --overwrite 2>/dev/null || true
done

echo "✓ Scenario reset"
