#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

# PVC Expansion
kubectl create namespace expand-test 2>/dev/null || true
kubectl apply -f - <<'MANIFEST'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: expandable-claim
  namespace: expand-test
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
MANIFEST

echo "✓ Scenario setup complete"
