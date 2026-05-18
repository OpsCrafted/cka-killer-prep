#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"

export KUBECONFIG

SCENARIO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Wait for cluster API
for i in {1..30}; do
  kubectl get nodes &>/dev/null && break
  sleep 1
done

# Deploy app with pod anti-affinity across nodes
kubectl apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: upgrade-app
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: upgrade-app
  template:
    metadata:
      labels:
        app: upgrade-app
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - upgrade-app
              topologyKey: kubernetes.io/hostname
      containers:
      - name: app
        image: nginx:latest
        ports:
        - containerPort: 80
EOF

# Wait for pods to be ready
kubectl wait --for=condition=Ready pod -l app=upgrade-app --timeout=30s 2>/dev/null || true

# Get any node that's not control-plane, or use any available node
NODE=$(kubectl get nodes -o jsonpath='{.items[?(@.metadata.labels.node-role\.kubernetes\.io/worker)].metadata.name}' | awk '{print $1}')
if [[ -z "$NODE" ]]; then
  # If no worker nodes, use the first non-control-plane node
  NODE=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}' | awk '{print $NF}')
fi
if [[ -z "$NODE" ]]; then
  # Fallback: use any node
  NODE=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
fi

# Cordon the node
kubectl cordon "$NODE" 2>/dev/null || true

echo "✓ Scenario setup complete: node $NODE cordoned with pods still running"
