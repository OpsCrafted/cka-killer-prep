#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

# Resource Limits
kubectl create namespace resource-test 2>/dev/null || true
kubectl apply -f - <<'MANIFEST'
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  namespace: resource-test
spec:
  containers:
  - name: app
    image: nginx
    resources:
      limits:
        cpu: "100m"
        memory: "128Mi"
MANIFEST

echo "✓ Scenario setup complete"
