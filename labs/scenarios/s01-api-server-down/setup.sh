#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

SCENARIO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Deploy baseline manifests
kubectl apply -f "$SCENARIO_DIR/manifests/deployment.yaml"

# Wait for pods to start
sleep 5

# Break the API server by stopping the container
docker exec "$CLUSTER_NAME-control-plane" sh -c 'pkill -f "kube-apiserver"' || true

echo "✓ Scenario setup complete: API server stopped"
