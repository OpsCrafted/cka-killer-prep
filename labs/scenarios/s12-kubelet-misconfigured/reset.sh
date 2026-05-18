#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

SCENARIO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl delete -f "$SCENARIO_DIR/manifests/deployment.yaml" --ignore-not-found

# Restore kubelet config (remove the bad override if possible)
docker exec "$CLUSTER_NAME-worker" sh -c 'systemctl restart kubelet' || true

sleep 5

echo "✓ Scenario reset complete"
