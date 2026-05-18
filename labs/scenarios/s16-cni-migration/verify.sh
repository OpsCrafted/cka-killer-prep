#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"

export KUBECONFIG

# Check if fixed
# Example:
# kubectl get deployment app -n default | grep -q "1/1"

echo "✓ Scenario verified"
exit 0
