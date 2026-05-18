#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

# GatewayClass Binding (optional, may not be available)
kubectl apply -f - <<'MANIFEST' 2>/dev/null || true
apiVersion: gateway.networking.k8s.io/v1beta1
kind: GatewayClass
metadata:
  name: example-gc
spec:
  controllerName: example.com/gateway-controller
MANIFEST

echo "✓ Scenario setup complete"
