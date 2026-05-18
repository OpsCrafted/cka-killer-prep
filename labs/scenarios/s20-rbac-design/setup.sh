#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

kubectl create namespace rbac-test 2>/dev/null || true
kubectl create serviceaccount app-sa -n rbac-test 2>/dev/null || true

# Create secret that pod needs to read
kubectl create secret generic app-secret \
  -n rbac-test \
  --from-literal=username=admin \
  --from-literal=password=secret123 \
  2>/dev/null || true

# Deploy pod that requires RBAC role to read secret
kubectl apply -f - <<'MANIFEST'
apiVersion: v1
kind: Pod
metadata:
  name: app-reader
  namespace: rbac-test
spec:
  serviceAccountName: app-sa
  restartPolicy: Never
  containers:
  - name: reader
    image: bitnami/kubectl:latest
    command:
    - /bin/sh
    - -c
    - |
      echo "Attempting to read secret app-secret..."
      kubectl get secret app-secret -n rbac-test -o jsonpath='{.data.username}' | base64 -d
      echo ""
      echo "Successfully read secret - RBAC is configured!"
MANIFEST

echo "✓ Scenario setup complete: Pod created without RBAC permissions to read secret"
