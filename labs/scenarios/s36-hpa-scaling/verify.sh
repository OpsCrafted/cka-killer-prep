#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: HPA exists
kubectl get hpa app-hpa -n hpa-test &>/dev/null || {
  echo "✗ FAILED: HPA app-hpa not found"
  exit 1
}

# Check 2: Verify target deployment exists
TARGET=$(kubectl get hpa app-hpa -n hpa-test -o jsonpath='{.spec.scaleTargetRef.name}' 2>/dev/null)
kubectl get deployment "$TARGET" -n hpa-test &>/dev/null || {
  echo "✗ FAILED: Target deployment $TARGET not found"
  exit 1
}

# Check 3: Verify min/max replicas are set
MIN_REPLICAS=$(kubectl get hpa app-hpa -n hpa-test -o jsonpath='{.spec.minReplicas}' 2>/dev/null)
MAX_REPLICAS=$(kubectl get hpa app-hpa -n hpa-test -o jsonpath='{.spec.maxReplicas}' 2>/dev/null)

if [[ -z "$MIN_REPLICAS" || -z "$MAX_REPLICAS" ]]; then
  echo "✗ FAILED: HPA minReplicas or maxReplicas not set"
  exit 1
fi

if [[ $MIN_REPLICAS -lt 1 || $MAX_REPLICAS -lt $MIN_REPLICAS ]]; then
  echo "✗ FAILED: HPA replica bounds invalid (min: $MIN_REPLICAS, max: $MAX_REPLICAS)"
  exit 1
fi

# Check 4: Verify HPA has valid metrics (v2 API)
HPA_JSON=$(kubectl get hpa app-hpa -n hpa-test -o json 2>/dev/null)

# Check for metrics (either CPU or custom metrics)
METRICS=$(echo "$HPA_JSON" | jq '.spec.metrics' 2>/dev/null)
if [[ -z "$METRICS" || "$METRICS" == "null" ]]; then
  echo "⚠ WARNING: HPA has no metrics defined (autoscaling may not work)"
fi

# Check 5: Verify current replicas is valid
CURRENT=$(kubectl get hpa app-hpa -n hpa-test -o jsonpath='{.status.currentReplicas}' 2>/dev/null)
DESIRED=$(kubectl get hpa app-hpa -n hpa-test -o jsonpath='{.status.desiredReplicas}' 2>/dev/null)

if [[ -z "$CURRENT" || -z "$DESIRED" ]]; then
  echo "⚠ WARNING: HPA status not yet populated"
fi

echo "✓ PASSED: HPA properly configured (target: $TARGET, min: $MIN_REPLICAS, max: $MAX_REPLICAS)"
exit 0
