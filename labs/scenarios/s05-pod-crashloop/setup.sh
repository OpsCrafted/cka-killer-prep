#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
SCENARIO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Apply deployment WITHOUT the ConfigMap — causes CrashLoop
kubectl apply -f "$SCENARIO_DIR/manifests/deployment.yaml"
sleep 3

echo "✓ Scenario setup complete: Pod in CrashLoopBackOff (missing ConfigMap)"
