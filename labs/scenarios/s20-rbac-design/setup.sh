#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done
# Create a deployment with insufficient RBAC
kubectl create namespace rbac-test 2>/dev/null || true
kubectl create serviceaccount app-sa -n rbac-test 2>/dev/null || true
kubectl apply -f - <<'MANIFEST'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  namespace: rbac-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      serviceAccountName: app-sa
      containers:
      - name: app
        image: nginx:latest
MANIFEST
echo "✓ Scenario setup complete: RBAC permissions missing"
