#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

# HPA
kubectl create namespace hpa-test 2>/dev/null || true
kubectl create deployment app -n hpa-test --image=nginx 2>/dev/null || true
sleep 2
kubectl apply -f - <<'MANIFEST'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
  namespace: hpa-test
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app
  minReplicas: 1
  maxReplicas: 3
MANIFEST

echo "✓ Scenario setup complete"
