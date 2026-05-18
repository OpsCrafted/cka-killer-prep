#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done
kubectl apply -f - <<MANIFEST
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: wait-for-cni
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: cni-check
  template:
    metadata:
      labels:
        k8s-app: cni-check
    spec:
      tolerations:
      - key: node-role.kubernetes.io/control-plane
        effect: NoSchedule
      containers:
      - name: pause
        image: pause:latest
MANIFEST
kubectl taint nodes --all cni-pending=true:NoSchedule 2>/dev/null || true
echo "✓ Scenario setup complete: CNI migration pending"
