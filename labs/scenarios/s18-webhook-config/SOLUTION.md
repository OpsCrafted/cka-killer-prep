# s18: Webhook Config — Solution

## Diagnosis

```bash
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations
```

## Fix

**Correct webhook URL/cert:**
```bash
kubectl edit validatingwebhookconfig <name>
# Fix: clientConfig.url, caBundle
```

**Or delete broken webhook:**
```bash
kubectl delete validatingwebhookconfig <name>
```

## Why

Webhook needs valid endpoint + cert. Wrong URL = connection failures.
