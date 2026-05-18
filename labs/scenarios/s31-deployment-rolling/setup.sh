#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

kubectl create namespace rollout-test 2>/dev/null || true

# Deployment with suboptimal rolling strategy (maxUnavailable causes downtime)
kubectl apply -f - <<'MANIFEST'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: rollout-test
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 0
      maxUnavailable: 1
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: app
        image: nginx:1.19
        ports:
        - containerPort: 80
MANIFEST

sleep 3

# Expose with service
kubectl apply -f - <<'MANIFEST'
apiVersion: v1
kind: Service
metadata:
  name: web-app
  namespace: rollout-test
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
MANIFEST

echo "✓ Scenario setup complete: Deployment with suboptimal rolling strategy"
