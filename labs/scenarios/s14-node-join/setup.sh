#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"

export KUBECONFIG

# Wait for API
for i in {1..30}; do
  kubectl get nodes &>/dev/null && break
  sleep 1
done

# Remove worker label from first node to simulate new node that hasn't joined properly
NODE=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
kubectl label node "$NODE" node-role.kubernetes.io/worker- 2>/dev/null || true

echo "✓ Scenario setup complete: node $NODE missing worker label"
