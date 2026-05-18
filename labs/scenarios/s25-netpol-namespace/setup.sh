#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

# Network Policy
kubectl create namespace netpol-test 2>/dev/null || true
kubectl create deployment app -n netpol-test --image=nginx 2>/dev/null || true
sleep 2
kubectl apply -f - <<'MANIFEST'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: netpol-test
spec:
  podSelector: {}
  policyTypes:
  - Ingress
MANIFEST

echo "✓ Scenario setup complete"
