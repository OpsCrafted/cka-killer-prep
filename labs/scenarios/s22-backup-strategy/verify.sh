#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check etcd backup exists
[[ -d /tmp/etcd-backup ]] && [[ -f /tmp/etcd-backup/backup.db ]] || { echo "✗ FAILED: No etcd backup"; exit 1; }
echo "✓ PASSED: etcd backup configured"
exit 0
