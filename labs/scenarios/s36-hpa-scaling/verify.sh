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

# Check 2: HPA has min replicas set
min_replicas=$(kubectl get hpa app-hpa -n hpa-test -o jsonpath='{.spec.minReplicas}')
if [[ -z "$min_replicas" ]] || [[ $min_replicas -lt 1 ]]; then
  echo "✗ FAILED: HPA minReplicas not set properly"
  exit 1
fi

# Check 3: HPA has max replicas set
max_replicas=$(kubectl get hpa app-hpa -n hpa-test -o jsonpath='{.spec.maxReplicas}')
if [[ -z "$max_replicas" ]] || [[ $max_replicas -le $min_replicas ]]; then
  echo "✗ FAILED: HPA maxReplicas not set properly"
  exit 1
fi

# Check 4: HPA has metric (CPU or custom)
metrics=$(kubectl get hpa app-hpa -n hpa-test -o jsonpath='{.spec.metrics}')
if [[ "$metrics" == "null" || "$metrics" == "[]" ]]; then
  echo "✗ FAILED: HPA has no metrics configured"
  exit 1
fi

# Check 5: Deployment exists and has replicas
kubectl get deployment app -n hpa-test &>/dev/null || {
  echo "✗ FAILED: Deployment app not found"
  exit 1
}

echo "✓ PASSED: HPA configured with metrics and scaling bounds"
exit 0
