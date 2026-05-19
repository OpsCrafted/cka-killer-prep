#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: Ingress exists with TLS config
INGRESS=$(kubectl get ingress tls-ingress -n ingress-test -o json 2>/dev/null) || {
  echo "✗ FAILED: Ingress tls-ingress not found in ingress-test namespace"
  exit 1
}

# Check 2: Ingress has TLS section configured
if ! echo "$INGRESS" | jq -e '.spec.tls[0].secretName' &>/dev/null; then
  echo "✗ FAILED: Ingress TLS not configured (no secretName found)"
  exit 1
fi

TLS_SECRET=$(echo "$INGRESS" | jq -r '.spec.tls[0].secretName')
if [[ -z "$TLS_SECRET" ]]; then
  echo "✗ FAILED: TLS secret name is empty"
  exit 1
fi

# Check 3: TLS secret exists
kubectl get secret "$TLS_SECRET" -n ingress-test &>/dev/null || {
  echo "✗ FAILED: TLS secret '$TLS_SECRET' not found"
  exit 1
}

# Check 4: Ingress has backend service configured
if ! echo "$INGRESS" | jq -e '.spec.rules[0].http.paths[0].backend.service.name' &>/dev/null; then
  echo "✗ FAILED: Ingress backend service not configured"
  exit 1
fi

SERVICE_NAME=$(echo "$INGRESS" | jq -r '.spec.rules[0].http.paths[0].backend.service.name')

# Check 5: Backend service exists (should be created by user to complete scenario)
kubectl get service "$SERVICE_NAME" -n ingress-test &>/dev/null || {
  echo "✗ FAILED: Backend service '$SERVICE_NAME' not found"
  exit 1
}

# Check 6: Backend service has endpoints (pod is available)
ENDPOINTS_COUNT=$(kubectl get endpoints "$SERVICE_NAME" -n ingress-test -o jsonpath='{.subsets[*].addresses[*].ip}' 2>/dev/null | wc -w)

if [[ $ENDPOINTS_COUNT -eq 0 ]]; then
  echo "✗ FAILED: Backend service has no endpoints (no pods running)"
  exit 1
fi

echo "✓ PASSED: Ingress TLS properly configured with working backend"
exit 0
