#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: Service exists
kubectl get service test-svc -n dns-test &>/dev/null || {
  echo "✗ FAILED: Service test-svc not found"
  exit 1
}

# Check 2: Service has valid ClusterIP
CLUSTER_IP=$(kubectl get service test-svc -n dns-test -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
if [[ -z "$CLUSTER_IP" || "$CLUSTER_IP" == "None" ]]; then
  echo "✗ FAILED: Service has no valid ClusterIP"
  exit 1
fi

# Check 3: Service has endpoints (pods backing it) — this fails if selector is wrong
ENDPOINTS=$(kubectl get endpoints test-svc -n dns-test -o jsonpath='{.subsets[0].addresses[*].ip}' 2>/dev/null)
if [[ -z "$ENDPOINTS" ]]; then
  echo "✗ FAILED: Service has no endpoints — selector may not match pod labels"
  exit 1
fi

# Check 4: Backend deployment exists
kubectl get deployment test-backend -n dns-test &>/dev/null || {
  echo "✗ FAILED: Deployment test-backend not found"
  exit 1
}

# Check 5: Backend pods running
BACKEND_PODS=$(kubectl get pods -n dns-test -l app=test-backend -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
if [[ -z "$BACKEND_PODS" ]]; then
  echo "✗ FAILED: No backend pods running with label app=test-backend"
  exit 1
fi

echo "✓ PASSED: Service DNS configured with correct selector and backing pods"
exit 0
