#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: PriorityClass exists
kubectl get priorityclass high-priority &>/dev/null || {
  echo "✗ FAILED: PriorityClass high-priority not found"
  exit 1
}

# Check 2: PriorityClass has value > 0
value=$(kubectl get priorityclass high-priority -o jsonpath='{.value}')
if [[ $value -le 0 ]]; then
  echo "✗ FAILED: PriorityClass value must be > 0 (current: $value)"
  exit 1
fi

# Check 3: Pod exists with priorityClassName set
kubectl get pod critical-app &>/dev/null || {
  echo "✗ FAILED: Pod critical-app not found"
  exit 1
}

# Check 4: Pod has priority class assigned
pod_priority=$(kubectl get pod critical-app -o jsonpath='{.spec.priorityClassName}')
if [[ "$pod_priority" != "high-priority" ]]; then
  echo "✗ FAILED: Pod does not have high-priority class (has: $pod_priority)"
  exit 1
fi

echo "✓ PASSED: Priority class created and applied to pod"
exit 0
