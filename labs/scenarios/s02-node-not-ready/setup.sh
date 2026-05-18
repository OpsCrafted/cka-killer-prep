#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

SCENARIO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Deploy baseline
kubectl apply -f "$SCENARIO_DIR/manifests/deployment.yaml"
sleep 3

# Stop kubelet on one worker to trigger NotReady
docker exec "$CLUSTER_NAME-worker" systemctl stop kubelet || true

echo "✓ Scenario setup complete: Worker node kubelet stopped"
