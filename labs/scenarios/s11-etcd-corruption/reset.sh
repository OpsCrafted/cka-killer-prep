#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG

kubectl delete namespace critical-app --ignore-not-found
rm -rf /tmp/etcd-backup

echo "✓ Scenario reset complete"
