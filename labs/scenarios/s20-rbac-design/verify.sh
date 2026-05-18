#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: Role exists that allows reading secrets
kubectl get role -n rbac-test 2>/dev/null | grep -q app-reader || {
  echo "✗ FAILED: Role 'app-reader' not found in rbac-test namespace"
  exit 1
}

# Check 2: RoleBinding exists connecting role to service account
kubectl get rolebinding -n rbac-test 2>/dev/null | grep -q app-reader || {
  echo "✗ FAILED: RoleBinding 'app-reader' not found in rbac-test namespace"
  exit 1
}

# Check 3: Pod can read the secret (should be in Succeeded state)
POD_STATUS=$(kubectl get pod app-reader -n rbac-test -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$POD_STATUS" != "Succeeded" ]]; then
  echo "✗ FAILED: Pod not in Succeeded state (current: $POD_STATUS)"
  exit 1
fi

# Check 4: Pod logs show successful secret read
LOGS=$(kubectl logs app-reader -n rbac-test 2>/dev/null)
if ! echo "$LOGS" | grep -q "Successfully read secret"; then
  echo "✗ FAILED: Pod logs don't show successful secret read"
  exit 1
fi

echo "✓ PASSED: RBAC policy configured correctly"
echo "  - Role 'app-reader' created"
echo "  - RoleBinding 'app-reader' connected to service account"
echo "  - Pod successfully read secret with proper permissions"
exit 0
