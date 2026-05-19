#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check 1: Service exists
kubectl get service app -n svc-test 2>/dev/null || {
  echo "✗ FAILED: Service app not found in svc-test namespace"
  exit 1
}

# Check 2: Service has valid ClusterIP
CLUSTER_IP=$(kubectl get service app -n svc-test -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
if [[ -z "$CLUSTER_IP" || "$CLUSTER_IP" == "None" ]]; then
  echo "✗ FAILED: Service has no valid ClusterIP"
  exit 1
fi

# Check 3: Service has endpoints (backend pods)
ENDPOINTS=$(kubectl get endpoints app -n svc-test -o jsonpath='{.subsets[0].addresses[*].ip}' 2>/dev/null)
if [[ -z "$ENDPOINTS" ]]; then
  echo "✗ FAILED: Service has no endpoints (no backing pods)"
  exit 1
fi

# Check 4: Service has port configured
PORT=$(kubectl get service app -n svc-test -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)
if [[ -z "$PORT" ]]; then
  echo "✗ FAILED: Service has no port configured"
  exit 1
fi

echo "✓ PASSED: Service discovery working (IP: $CLUSTER_IP, Port: $PORT)"
exit 0
