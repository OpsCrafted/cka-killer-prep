#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done
kubectl create namespace backup-test 2>/dev/null || true
kubectl apply -f - <<'MANIFEST'
apiVersion: v1
kind: ConfigMap
metadata:
  name: backup-config
  namespace: backup-test
data:
  backup-schedule: "daily at 2am"
MANIFEST
echo "✓ Scenario setup complete: etcd backup needed"
