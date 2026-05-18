#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done
# Webhook config with wrong endpoint
kubectl apply -f - <<'MANIFEST' 2>/dev/null || true
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  name: broken-webhook
webhooks:
- name: broken.example.com
  admissionReviewVersions: ["v1"]
  clientConfig:
    url: https://broken.example.com:443/mutate
  rules:
  - operations: ["CREATE"]
    apiGroups: [""]
    apiVersions: ["v1"]
    resources: ["pods"]
MANIFEST
echo "✓ Scenario setup complete: webhook misconfigured"
