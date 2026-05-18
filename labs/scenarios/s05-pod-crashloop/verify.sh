#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check pod is Running
POD=$(kubectl get pods -l app=crashloop-demo -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -z "$POD" ]; then
  echo "✗ FAILED: No pod found"
  exit 1
fi

STATUS=$(kubectl get pod "$POD" -o jsonpath='{.status.phase}')
if [ "$STATUS" != "Running" ]; then
  echo "✗ FAILED: Pod status is $STATUS (expected Running)"
  exit 1
fi

echo "✓ PASSED: Pod is Running"
exit 0
