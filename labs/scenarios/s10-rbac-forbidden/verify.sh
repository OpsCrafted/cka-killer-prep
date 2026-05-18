#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check RoleBinding exists
if ! kubectl get rolebinding app-reader-binding &>/dev/null 2>&1; then
  echo "✗ FAILED: RoleBinding not found"
  exit 1
fi

# Check pod can access API (pod logs won't show Forbidden)
POD=$(kubectl get pods -l app=rbac-test -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

# Try to get logs (if pod can't auth to API, it will show errors)
if kubectl logs "$POD" --tail=3 2>&1 | grep -i "forbidden" >/dev/null; then
  echo "✗ FAILED: Pod still getting Forbidden errors"
  exit 1
fi

echo "✓ PASSED: RBAC permissions working"
exit 0
