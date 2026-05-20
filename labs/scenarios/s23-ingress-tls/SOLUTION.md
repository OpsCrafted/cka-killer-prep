# s23: Ingress TLS — Solution

## Diagnosis

Check Ingress for TLS configuration:
```bash
kubectl get ingress -n ingress-test
kubectl describe ingress tls-ingress -n ingress-test
# Note: secretName: tls-secret (but secret doesn't exist)
```

Check if TLS secret exists:
```bash
kubectl get secret -n ingress-test
# tls-secret is MISSING
```

## Fix

Generate self-signed cert:
```bash
openssl req -x509 -newkey rsa:2048 -keyout /tmp/tls.key -out /tmp/tls.crt \
  -days 365 -nodes -subj "/CN=example.com"
```

Create TLS secret in correct namespace:
```bash
kubectl create secret tls tls-secret -n ingress-test \
  --cert=/tmp/tls.crt --key=/tmp/tls.key
```

Verify Ingress now has valid TLS:
```bash
kubectl describe ingress tls-ingress -n ingress-test
# Should show: TLS Secret: tls-secret (Terminating HTTPS traffic)
```

## Why

Ingress references TLS secret that doesn't exist. Learner must:
1. Generate certificate
2. Create secret in same namespace as Ingress
3. Verify secret is referenced correctly

## Common Mistakes

- Secret in wrong namespace (ingress-nginx vs ingress-test)
- Typo in secret name
- Wrong cert format or missing key
