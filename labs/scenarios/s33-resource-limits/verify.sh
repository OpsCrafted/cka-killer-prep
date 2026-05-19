#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: Pod exists
kubectl get pod app-pod -n resource-test &>/dev/null || {
  echo "✗ FAILED: Pod app-pod not found"
  exit 1
}

# Check 2: CPU limit set
cpu_limit=$(kubectl get pod app-pod -n resource-test -o jsonpath='{.spec.containers[0].resources.limits.cpu}')
if [[ -z "$cpu_limit" ]]; then
  echo "✗ FAILED: No CPU limit set"
  exit 1
fi

# Check 3: Memory limit set
mem_limit=$(kubectl get pod app-pod -n resource-test -o jsonpath='{.spec.containers[0].resources.limits.memory}')
if [[ -z "$mem_limit" ]]; then
  echo "✗ FAILED: No memory limit set"
  exit 1
fi

# Check 4: CPU request set
cpu_request=$(kubectl get pod app-pod -n resource-test -o jsonpath='{.spec.containers[0].resources.requests.cpu}')
if [[ -z "$cpu_request" ]]; then
  echo "✗ FAILED: No CPU request set"
  exit 1
fi

# Check 5: Memory request set
mem_request=$(kubectl get pod app-pod -n resource-test -o jsonpath='{.spec.containers[0].resources.requests.memory}')
if [[ -z "$mem_request" ]]; then
  echo "✗ FAILED: No memory request set"
  exit 1
fi

echo "✓ PASSED: Resource limits and requests configured"
exit 0
