#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"

export KUBECONFIG

# Clean up audit scenario files
rm -rf /tmp/audit-scenario 2>/dev/null || true

echo "✓ Scenario reset"
