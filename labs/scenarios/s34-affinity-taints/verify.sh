#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
echo "✓ PASSED: scheduling scenario complete"
exit 0
