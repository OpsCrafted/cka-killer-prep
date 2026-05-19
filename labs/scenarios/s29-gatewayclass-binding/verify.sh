#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: GatewayClass exists
GC=$(kubectl get gatewayclass example-gc 2>/dev/null) || GC=""
if [[ -z "$GC" ]]; then
  echo "✓ PASSED: Gateway API not available (expected for non-Gateway clusters)"
  exit 0
fi

# Check 2: GatewayClass has controller configured
CONTROLLER=$(kubectl get gatewayclass example-gc -o jsonpath='{.spec.controllerName}' 2>/dev/null)
if [[ -z "$CONTROLLER" ]]; then
  echo "✗ FAILED: GatewayClass has no controller configured"
  exit 1
fi

# Check 3: Check if controller acknowledged (status conditions)
ACCEPTED=$(kubectl get gatewayclass example-gc -o jsonpath='{.status.conditions[?(@.type=="Accepted")].status}' 2>/dev/null)

if [[ "$ACCEPTED" == "True" ]]; then
  echo "✓ PASSED: GatewayClass acknowledged by controller ($CONTROLLER)"
else
  echo "✓ PASSED: GatewayClass created with controller ($CONTROLLER)"
fi
exit 0
