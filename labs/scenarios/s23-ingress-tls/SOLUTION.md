# s23: Ingress TLS — Solution

## Diagnosis

```bash
kubectl get ingress -A
kubectl describe ingress <name>
kubectl get secret -n ingress-nginx
```

## Fix

**Create TLS secret:**
```bash
kubectl create secret tls <name> --cert=tls.crt --key=tls.key -n ingress-nginx
```

**Update Ingress:**
```bash
kubectl patch ingress <name> -p '{"spec":{"tls":[{"hosts":["example.com"],"secretName":"<name>"}]}}'
```

**Verify:**
```bash
curl -k https://example.com
```

## Why

Ingress needs TLS cert. Secret must exist before Ingress references it.

## Mistakes

- Secret in wrong namespace
- Wrong cert format
