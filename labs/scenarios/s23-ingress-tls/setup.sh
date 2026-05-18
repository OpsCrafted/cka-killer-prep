#!/bin/bash
set -e
CLUSTER_NAME="$1"
KUBECONFIG="$2"
export KUBECONFIG
for i in {1..30}; do kubectl get nodes &>/dev/null && break; sleep 1; done

# Ingress with TLS
kubectl create namespace ingress-test 2>/dev/null || true
kubectl create secret tls tls-secret -n ingress-test --cert=/etc/ssl/certs/ssl-cert-snakeoil.pem --key=/etc/ssl/private/ssl-cert-snakeoil.key 2>/dev/null || true
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
