#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

# Local Storage Provisioner
kubectl create namespace local-storage 2>/dev/null || true
kubectl apply -f - <<'MANIFEST'
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
MANIFEST

echo "✓ Scenario setup complete"
