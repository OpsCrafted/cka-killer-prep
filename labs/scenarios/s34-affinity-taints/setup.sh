#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

# Taints and Affinity
kubectl taint nodes --all reserved=true:NoSchedule 2>/dev/null || true
kubectl apply -f - <<'MANIFEST'
apiVersion: v1
kind: Pod
metadata:
  name: affinity-pod
spec:
  tolerations:
  - key: reserved
    operator: Equal
    value: "true"
    effect: NoSchedule
  containers:
  - name: app
    image: nginx
MANIFEST

echo "✓ Scenario setup complete"
