#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
[[ -d /tmp/etcd-backup ]] || { echo "✗ FAILED: No etcd backup directory"; exit 1; }
[[ -f /tmp/etcd-backup/backup.db ]] || { echo "✗ FAILED: No etcd backup file"; exit 1; }
echo "✓ PASSED: etcd backup configured"
exit 0
