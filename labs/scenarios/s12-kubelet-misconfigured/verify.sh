#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check worker node is Ready
NODE_STATUS=$(kubectl get nodes -l node-role.kubernetes.io/worker -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)

if [ "$NODE_STATUS" != "True" ]; then
  echo "✗ FAILED: Worker node not Ready"
  exit 1
fi

# Check pods can run on worker
RUNNING=$(kubectl get pods -l app=test-kubelet-fix -o jsonpath='{.items[*].status.phase}' | grep -o "Running" | wc -l)
TOTAL=$(kubectl get pods -l app=test-kubelet-fix --no-headers | wc -l)

if [ "$RUNNING" -lt "$TOTAL" ]; then
  echo "✗ FAILED: Not all pods Running ($RUNNING/$TOTAL)"
  exit 1
fi

echo "✓ PASSED: Kubelet healthy and pods running"
exit 0
