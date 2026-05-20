#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

kubectl create namespace priority-test 2>/dev/null || true
kubectl delete pod -n priority-test low-priority high-priority 2>/dev/null || true

# Low-priority pod (reserves CPU to force contention)
kubectl apply -f - <<'MANIFEST'
apiVersion: v1
kind: Pod
metadata:
  name: low-priority
  namespace: priority-test
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        cpu: 700m
      limits:
        cpu: 700m
MANIFEST

# High-priority pod (without priority class — will be Pending)
kubectl apply -f - <<'MANIFEST'
apiVersion: v1
kind: Pod
metadata:
  name: high-priority
  namespace: priority-test
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        cpu: 500m
      limits:
        cpu: 500m
MANIFEST

echo "✓ Scenario setup complete"
