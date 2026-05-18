#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check all pods are Running
RUNNING=$(kubectl get pods -l app=pending-app -o jsonpath='{.items[*].status.phase}' | grep -o "Running" | wc -l)
TOTAL=$(kubectl get pods -l app=pending-app --no-headers | wc -l)

if [ "$RUNNING" -lt "$TOTAL" ]; then
  echo "✗ FAILED: Not all pods Running ($RUNNING/$TOTAL)"
  kubectl get pods -l app=pending-app
  exit 1
fi

echo "✓ PASSED: All pods Running"
exit 0
