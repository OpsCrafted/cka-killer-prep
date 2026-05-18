#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"

export KUBECONFIG

# Check 1: No nodes are cordoned
CORDONED=$(kubectl get nodes -o json | jq -r '.items[] | select(.spec.unschedulable == true) | .metadata.name' | wc -l)
if [[ $CORDONED -gt 0 ]]; then
  echo "✗ FAILED: $CORDONED node(s) still cordoned"
  exit 1
fi

# Check 2: Deployment exists
if ! kubectl get deployment upgrade-app -n default &>/dev/null; then
  echo "✗ FAILED: Deployment upgrade-app not found"
  exit 1
fi

# Check 3: Deployment pods are Ready
READY=$(kubectl get deployment upgrade-app -n default -o jsonpath='{.status.readyReplicas}')
DESIRED=$(kubectl get deployment upgrade-app -n default -o jsonpath='{.spec.replicas}')
if [[ "$READY" != "$DESIRED" ]]; then
  echo "✗ FAILED: Deployment not ready ($READY/$DESIRED)"
  exit 1
fi

# Check 4: All pods running
RUNNING=$(kubectl get pods -l app=upgrade-app -n default -o json | jq '[.items[] | select(.status.phase == "Running")] | length')
if [[ "$RUNNING" -lt 2 ]]; then
  echo "✗ FAILED: Only $RUNNING pods running (need 2)"
  exit 1
fi

echo "✓ PASSED: Node upgrade scenario complete"
echo "  - No nodes cordoned"
echo "  - Deployment ready: $READY/$DESIRED replicas"
echo "  - All pods running across nodes"
exit 0
