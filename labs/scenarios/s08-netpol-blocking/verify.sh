#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check that frontend pod can reach backend service
FRONTEND_POD=$(kubectl get pods -l app=frontend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$FRONTEND_POD" ]; then
  echo "✗ FAILED: Frontend pod not found"
  exit 1
fi

# Test connectivity
if kubectl exec "$FRONTEND_POD" -- wget -q -T 3 -O- http://backend:80 >/dev/null 2>&1; then
  echo "✓ PASSED: Pod-to-pod communication working"
  exit 0
else
  echo "✗ FAILED: Frontend cannot reach backend"
  exit 1
fi
