#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"

export KUBECONFIG

# Clean up
# Example:
# kubectl delete all --all -n default

echo "✓ Scenario reset"
