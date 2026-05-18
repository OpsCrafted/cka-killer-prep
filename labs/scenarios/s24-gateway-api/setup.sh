#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

kubectl create namespace gateway-test 2>/dev/null || true
# Gateway API (optional, may not be available)
kubectl apply -f - <<'MANIFEST' 2>/dev/null || true
apiVersion: gateway.networking.k8s.io/v1beta1
kind: GatewayClass
metadata:
  name: demo-gateway
spec:
  controllerName: example.com/demo
MANIFEST

echo "✓ Scenario setup complete"
