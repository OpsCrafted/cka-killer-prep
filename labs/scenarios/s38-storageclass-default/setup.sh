#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

kubectl apply -f - <<'MANIFEST'
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: kubernetes.io/host-path
MANIFEST

kubectl patch storageclass standard -p "{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"true\"}}}" 2>/dev/null || true

echo "✓ Scenario setup complete"
