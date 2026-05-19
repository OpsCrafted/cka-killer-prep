#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: Pod exists
kubectl get pod affinity-pod &>/dev/null || {
  echo "✗ FAILED: Pod affinity-pod not found"
  exit 1
}

# Check 2: Pod is Running
status=$(kubectl get pod affinity-pod -o jsonpath='{.status.phase}')
if [[ "$status" != "Running" ]]; then
  echo "✗ FAILED: Pod not Running (status: $status)"
  exit 1
fi

# Check 3: Pod has nodeAffinity or tolerations
affinity=$(kubectl get pod affinity-pod -o jsonpath='{.spec.affinity}')
tolerations=$(kubectl get pod affinity-pod -o jsonpath='{.spec.tolerations}')
if [[ "$affinity" == "null" || "$affinity" == "{}" ]] && [[ "$tolerations" == "null" || "$tolerations" == "{}" ]]; then
  echo "✗ FAILED: Pod has no affinity or tolerations"
  exit 1
fi

# Check 4: Verify pod scheduled on specific node (if node selector/affinity used)
node=$(kubectl get pod affinity-pod -o jsonpath='{.spec.nodeName}')
if [[ -z "$node" ]]; then
  echo "✗ FAILED: Pod not scheduled on a node"
  exit 1
fi

echo "✓ PASSED: Pod affinity/taints configured and pod scheduled"
exit 0
