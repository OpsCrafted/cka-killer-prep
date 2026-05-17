#!/bin/bash
set -euo pipefail

CLUSTER_NAME="${1:-cka-lab}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Resetting cluster '$CLUSTER_NAME' to clean state..."
"$SCRIPT_DIR/create-cluster.sh" "$CLUSTER_NAME"
