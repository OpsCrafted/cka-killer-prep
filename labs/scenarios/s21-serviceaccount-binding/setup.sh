#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

kubectl create namespace app 2>/dev/null || true
kubectl create namespace shared 2>/dev/null || true
kubectl create serviceaccount app-reader -n app 2>/dev/null || true

# Secret in shared namespace that app namespace needs to access
kubectl create secret generic shared-secret \
  -n shared \
  --from-literal=api-key=secret-123 \
  2>/dev/null || true

# Pod that requires cross-namespace permissions
kubectl apply -f - <<'MANIFEST'
apiVersion: v1
kind: Pod
metadata:
  name: cross-ns-reader
  namespace: app
spec:
  serviceAccountName: app-reader
  restartPolicy: Never
  containers:
  - name: reader
    image: bitnami/kubectl:latest
    command:
    - /bin/sh
    - -c
    - |
      echo "Attempting to read secret from shared namespace..."
      kubectl get secret shared-secret -n shared -o jsonpath='{.data.api-key}' | base64 -d
      echo ""
      echo "Success - cross-namespace RBAC configured!"
MANIFEST

echo "✓ Scenario setup complete: ServiceAccount requires cross-namespace permissions"
