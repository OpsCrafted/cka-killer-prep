#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"

export KUBECONFIG

# Uncordon all nodes
for node in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
  kubectl uncordon "$node" 2>/dev/null || true
done

# Delete deployment
kubectl delete deployment upgrade-app -n default 2>/dev/null || true

# Wait for pods to be deleted
kubectl wait --for=delete pod -l app=upgrade-app --timeout=10s 2>/dev/null || true

echo "✓ Scenario reset"
