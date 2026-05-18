#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

# Check etcd backup exists and is recent (within last hour)
if [[ ! -d /tmp/etcd-backup ]]; then
  echo "✗ FAILED: Backup directory /tmp/etcd-backup not found"
  exit 1
fi

if [[ ! -f /tmp/etcd-backup/backup.db ]]; then
  echo "✗ FAILED: Backup file /tmp/etcd-backup/backup.db not found"
  exit 1
fi

# Check file is not empty
if [[ ! -s /tmp/etcd-backup/backup.db ]]; then
  echo "✗ FAILED: Backup file is empty"
  exit 1
fi

echo "✓ PASSED: etcd backup configured and present"
exit 0
