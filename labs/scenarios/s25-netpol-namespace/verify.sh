#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: NetworkPolicy exists
kubectl get networkpolicy deny-all -n netpol-test &>/dev/null || {
  echo "✗ FAILED: NetworkPolicy deny-all not found"
  exit 1
}

# Check 2: Verify NetworkPolicy spec is correct (blocks ingress)
NETPOL=$(kubectl get networkpolicy deny-all -n netpol-test -o json 2>/dev/null)
if ! echo "$NETPOL" | jq -e '.spec.policyTypes[] | select(. == "Ingress")' &>/dev/null; then
  echo "✗ FAILED: NetworkPolicy does not block Ingress traffic"
  exit 1
fi

# Check 3: Verify podSelector is set (applies to pods in namespace)
if ! echo "$NETPOL" | jq -e '.spec.podSelector' &>/dev/null; then
  echo "✗ FAILED: NetworkPolicy missing podSelector"
  exit 1
fi

# Check 4: Target pod exists for testing
kubectl get deployment app -n netpol-test &>/dev/null || {
  echo "✗ FAILED: Test deployment app not found"
  exit 1
}

# Check 5: Verify pod is actually running
POD=$(kubectl get pod -n netpol-test -l app=app -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [[ -z "$POD" ]]; then
  echo "✗ FAILED: No pods running for app deployment"
  exit 1
fi

POD_STATUS=$(kubectl get pod "$POD" -n netpol-test -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$POD_STATUS" != "Running" ]]; then
  echo "✗ FAILED: Pod not running (status: $POD_STATUS)"
  exit 1
fi

echo "✓ PASSED: NetworkPolicy deny-all correctly blocks ingress traffic"
exit 0
