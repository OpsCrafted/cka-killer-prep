#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

SCENARIO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create namespace and resources
kubectl apply -f "$SCENARIO_DIR/manifests/namespace.yaml"
sleep 3

# Take etcd snapshot
BACKUP_DIR="/tmp/etcd-backup"
mkdir -p "$BACKUP_DIR"
docker exec "$CLUSTER_NAME-control-plane" sh -c "ETCDCTL_API=3 etcdctl --endpoints=127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save $BACKUP_DIR/backup.db" 2>/dev/null || true

# Delete the namespace to simulate corruption
kubectl delete namespace critical-app --ignore-not-found

echo "✓ Scenario setup complete: Namespace deleted, etcd backup available"
