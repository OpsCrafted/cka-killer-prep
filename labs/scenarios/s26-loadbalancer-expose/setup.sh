#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

# LoadBalancer Service
kubectl create namespace lb-test 2>/dev/null || true
kubectl create deployment app -n lb-test --image=nginx 2>/dev/null || true
sleep 2
kubectl apply -f - <<'MANIFEST'
apiVersion: v1
kind: Service
metadata:
  name: app-lb
  namespace: lb-test
spec:
  selector:
    app: app
  type: LoadBalancer
  ports:
  - port: 80
MANIFEST

echo "✓ Scenario setup complete"
