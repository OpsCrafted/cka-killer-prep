#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: ClusterRole exists
kubectl get clusterrole app-reader &>/dev/null || {
  echo "✗ FAILED: ClusterRole 'app-reader' not found"
  exit 1
}

# Check 2: ClusterRoleBinding exists
kubectl get clusterrolebinding app-reader &>/dev/null || {
  echo "✗ FAILED: ClusterRoleBinding 'app-reader' not found"
  exit 1
}

# Check 3: Pod succeeded
POD_STATUS=$(kubectl get pod cross-ns-reader -n app -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$POD_STATUS" != "Succeeded" ]]; then
  echo "✗ FAILED: Pod not Succeeded (current: $POD_STATUS)"
  exit 1
fi

# Check 4: Pod logs show success
LOGS=$(kubectl logs cross-ns-reader -n app 2>/dev/null)
if ! echo "$LOGS" | grep -q "Success - cross-namespace"; then
  echo "✗ FAILED: Pod logs don't show successful access"
  exit 1
fi

echo "✓ PASSED: Cross-namespace RBAC configured"
exit 0
