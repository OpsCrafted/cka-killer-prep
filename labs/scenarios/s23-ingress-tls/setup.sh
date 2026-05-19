#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

# Ingress with TLS
kubectl create namespace ingress-test 2>/dev/null || true

# Generate self-signed certificate inline
openssl req -x509 -newkey rsa:2048 -keyout /tmp/tls.key -out /tmp/tls.crt -days 365 -nodes \
  -subj "/CN=example.com" 2>/dev/null || true

# Create TLS secret from cert
kubectl create secret tls tls-secret -n ingress-test --cert=/tmp/tls.crt --key=/tmp/tls.key 2>/dev/null || true

# Create backend deployment and service
kubectl create deployment web -n ingress-test --image=nginx 2>/dev/null || true

# Wait for pod to be ready
for i in {1..30}; do
  READY=$(kubectl get deployment web -n ingress-test -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo 0)
  [[ "$READY" -gt 0 ]] && break
  sleep 1
done

kubectl expose deployment web -n ingress-test --port=80 --target-port=80 2>/dev/null || true
sleep 1

# Create Ingress with TLS
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

echo "✓ Scenario setup complete"
