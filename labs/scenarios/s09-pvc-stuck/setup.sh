#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

SCENARIO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create PVC without matching StorageClass
kubectl apply -f "$SCENARIO_DIR/manifests/pvc.yaml"
sleep 3

echo "✓ Scenario setup complete: PVC pending (storageClassName mismatch)"
