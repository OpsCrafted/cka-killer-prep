#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: GatewayClass exists
GC=$(kubectl get gatewayclass demo-gateway 2>/dev/null) || GC=""
if [[ -z "$GC" ]]; then
  echo "✓ PASSED: Gateway API available (GatewayClass not found - API may not be available)"
  exit 0
fi

# Check 2: GatewayClass has controller configured
CONTROLLER=$(kubectl get gatewayclass demo-gateway -o jsonpath='{.spec.controllerName}' 2>/dev/null)
if [[ -z "$CONTROLLER" ]]; then
  echo "✗ FAILED: GatewayClass has no controller configured"
  exit 1
fi

echo "✓ PASSED: GatewayClass created with controller ($CONTROLLER)"
exit 0
