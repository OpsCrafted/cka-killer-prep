#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

# Ingress with TLS (broken state)
kubectl create namespace ingress-test 2>/dev/null || true

# Create backend deployment and service
kubectl create deployment web -n ingress-test --image=nginx 2>/dev/null || true

# Wait for deployment to have ready replicas
timeout 60 kubectl rollout status deployment/web -n ingress-test 2>/dev/null || true

# Expose deployment as service
kubectl expose deployment web -n ingress-test --port=80 --target-port=80 2>/dev/null || true

# Short wait for endpoints
sleep 2

# Create Ingress with TLS reference but NO TLS secret (broken)
kubectl apply -f - <<'MANIFEST'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
  namespace: ingress-test
spec:
  tls:
  - hosts:
    - example.com
    secretName: tls-secret
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web
            port:
              number: 80
MANIFEST

echo "✓ Scenario setup complete (TLS secret missing - learner must create it)"
