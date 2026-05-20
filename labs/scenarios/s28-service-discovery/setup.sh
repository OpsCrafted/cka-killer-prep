#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

# Service Discovery (broken: service has wrong selector)
kubectl delete namespace svc-test 2>/dev/null || true
sleep 1
kubectl create namespace svc-test
kubectl create deployment app -n svc-test --image=nginx 2>/dev/null || true
sleep 2
# Service with wrong selector - won't match deployment pods
kubectl apply -f - <<'MANIFEST'
apiVersion: v1
kind: Service
metadata:
  name: app
  namespace: svc-test
spec:
  type: ClusterIP
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    tier: backend
MANIFEST

echo "✓ Scenario setup complete"
