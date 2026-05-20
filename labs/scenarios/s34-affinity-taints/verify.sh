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

# Check 2: Pod is Running (must have toleration for taint)
status=$(kubectl get pod affinity-pod -o jsonpath='{.status.phase}')
if [[ "$status" != "Running" ]]; then
  echo "✗ FAILED: Pod not Running (status: $status) — likely needs toleration for taint"
  exit 1
fi

# Check 3: Pod has tolerations or affinity constraints configured
tolerations=$(kubectl get pod affinity-pod -o jsonpath='{.spec.tolerations}')
affinity=$(kubectl get pod affinity-pod -o jsonpath='{.spec.affinity}')
if [[ "$tolerations" == "null" || "$tolerations" == "{}" ]]; then
  if [[ "$affinity" == "null" || "$affinity" == "{}" ]]; then
    echo "✗ FAILED: Pod has no tolerations or affinity constraints"
    exit 1
  fi
fi

echo "✓ PASSED: Pod affinity/taints configured and pod scheduled"
exit 0
