#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Wait for API server to be responsive
for i in {1..30}; do
  kubectl get nodes &>/dev/null && break
  sleep 1
done

SCENARIO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Apply deployment WITHOUT the ConfigMap — causes CrashLoop
kubectl apply -f "$SCENARIO_DIR/manifests/deployment.yaml"
sleep 3

echo "✓ Scenario setup complete: Pod in CrashLoopBackOff (missing ConfigMap)"
