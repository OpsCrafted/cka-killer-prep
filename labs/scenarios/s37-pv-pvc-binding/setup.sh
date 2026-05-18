#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"

export KUBECONFIG

# Introduce failure here
# Example:
# kubectl scale deployment app --replicas=0 -n default

echo "✓ Scenario setup complete"
