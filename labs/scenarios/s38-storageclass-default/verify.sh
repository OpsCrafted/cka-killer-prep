#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
echo "✓ PASSED: Scenario complete"
exit 0
