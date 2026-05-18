#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check service has endpoints
ENDPOINT=$(kubectl get svc backend -o jsonpath='{.spec.selector.app}' 2>/dev/null)
POD_LABEL=$(kubectl get pods -l app=backend -o jsonpath='{.items[0].metadata.labels.app}' 2>/dev/null)

if [ "$ENDPOINT" != "$POD_LABEL" ]; then
  echo "✗ FAILED: Service selector doesn't match pod labels"
  echo "Service selector: $ENDPOINT"
  echo "Pod label: $POD_LABEL"
  exit 1
fi

# Verify endpoints exist
ENDPOINTS=$(kubectl get svc backend -o jsonpath='{.subsets[0].addresses}' 2>/dev/null)
if [ -z "$ENDPOINTS" ]; then
  echo "✗ FAILED: Service has no endpoints"
  kubectl get svc backend
  exit 1
fi

echo "✓ PASSED: Service has endpoints"
exit 0
