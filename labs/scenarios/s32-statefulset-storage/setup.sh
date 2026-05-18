#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

# StatefulSet with Storage
kubectl create namespace stateful-test 2>/dev/null || true
kubectl apply -f - <<'MANIFEST'
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: db
  namespace: stateful-test
spec:
  serviceName: db
  replicas: 1
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
      - name: db
        image: postgres:13
        ports:
        - containerPort: 5432
MANIFEST

echo "✓ Scenario setup complete"
