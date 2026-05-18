#!/bin/bash
set -e

CLUSTER_NAME="$1"
KUBECONFIG="$2"

export KUBECONFIG

# Wait for API
for i in {1..30}; do
  kubectl get nodes &>/dev/null && break
  sleep 1
done

# Create audit policy file (but don't apply it yet - that's the task)
mkdir -p /tmp/audit-scenario

cat > /tmp/audit-scenario/audit-policy.yaml << 'AUDIT'
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
  omitStages:
  - RequestReceived
AUDIT

echo "Audit policy template created at /tmp/audit-scenario/audit-policy.yaml"
echo "Task: Configure kube-apiserver to use this audit policy"
echo "✓ Scenario setup complete: audit logging not configured"
