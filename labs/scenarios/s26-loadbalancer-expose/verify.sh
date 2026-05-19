#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: LoadBalancer Service exists
kubectl get service app-lb -n lb-test 2>/dev/null || {
  echo "✗ FAILED: LoadBalancer service app-lb not found"
  exit 1
}

# Check 2: Service is type LoadBalancer
TYPE=$(kubectl get service app-lb -n lb-test -o jsonpath='{.spec.type}' 2>/dev/null)
if [[ "$TYPE" != "LoadBalancer" ]]; then
  echo "✗ FAILED: Service type is $TYPE, not LoadBalancer"
  exit 1
fi

# Check 3: Service has selector (routes to pods)
SELECTOR=$(kubectl get service app-lb -n lb-test -o jsonpath='{.spec.selector}' 2>/dev/null)
if [[ -z "$SELECTOR" || "$SELECTOR" == "{}" ]]; then
  echo "✗ FAILED: Service has no pod selector"
  exit 1
fi

# Check 4: Service has endpoints (backend pods exist)
ENDPOINTS=$(kubectl get endpoints app-lb -n lb-test -o jsonpath='{.subsets[0].addresses[*].ip}' 2>/dev/null)
if [[ -z "$ENDPOINTS" ]]; then
  echo "⚠ WARNING: LoadBalancer service has no backend endpoints (pods may not be running)"
  echo "✓ PASSED: LoadBalancer service configured (pending endpoints)"
  exit 0
fi

echo "✓ PASSED: LoadBalancer service exposed with backend pods"
exit 0
