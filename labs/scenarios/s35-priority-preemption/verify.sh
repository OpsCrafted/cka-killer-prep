#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: High-priority pod exists
kubectl get pod -n priority-test high-priority &>/dev/null || {
  echo "✗ FAILED: Pod high-priority not found in priority-test namespace"
  exit 1
}

# Check 2: High-priority pod is Running (requires priority class to preempt low-priority)
status=$(kubectl get pod -n priority-test high-priority -o jsonpath='{.status.phase}')
if [[ "$status" != "Running" ]]; then
  echo "✗ FAILED: Pod high-priority not Running (status: $status) — needs priority class to preempt"
  exit 1
fi

# Check 3: High-priority pod has priorityClassName set
pod_priority=$(kubectl get pod -n priority-test high-priority -o jsonpath='{.spec.priorityClassName}')
if [[ -z "$pod_priority" || "$pod_priority" == "null" ]]; then
  echo "✗ FAILED: Pod high-priority has no priorityClassName set"
  exit 1
fi

echo "✓ PASSED: High-priority pod running with priority class enabling preemption"
exit 0
