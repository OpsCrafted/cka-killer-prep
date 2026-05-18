#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

SCENARIO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl delete -f "$SCENARIO_DIR/manifests/rbac.yaml" --ignore-not-found
kubectl delete rolebinding app-reader-binding --ignore-not-found
kubectl delete role app-reader --ignore-not-found

echo "✓ Scenario reset complete"
