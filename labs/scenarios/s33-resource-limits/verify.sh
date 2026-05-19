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

# Check 2: Pod is running
POD_STATUS=$(kubectl get pod app-pod -n resource-test -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$POD_STATUS" != "Running" ]]; then
  echo "✗ FAILED: Pod not running (status: $POD_STATUS)"
  exit 1
fi

# Check 3: Verify CPU limit is set
CPU_LIMIT=$(kubectl get pod app-pod -n resource-test -o jsonpath='{.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
if [[ -z "$CPU_LIMIT" ]]; then
  echo "✗ FAILED: CPU limit not set"
  exit 1
fi

# Check 4: Verify memory limit is set
MEMORY_LIMIT=$(kubectl get pod app-pod -n resource-test -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null)
if [[ -z "$MEMORY_LIMIT" ]]; then
  echo "✗ FAILED: Memory limit not set"
  exit 1
fi

# Check 5: Verify requests are also set (best practice)
CPU_REQUEST=$(kubectl get pod app-pod -n resource-test -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
MEMORY_REQUEST=$(kubectl get pod app-pod -n resource-test -o jsonpath='{.spec.containers[0].resources.requests.memory}' 2>/dev/null)

if [[ -z "$CPU_REQUEST" || -z "$MEMORY_REQUEST" ]]; then
  echo "⚠ WARNING: Resource requests not set (only limits set)"
fi

echo "✓ PASSED: Resource limits properly configured (CPU: $CPU_LIMIT, Memory: $MEMORY_LIMIT)"
exit 0
