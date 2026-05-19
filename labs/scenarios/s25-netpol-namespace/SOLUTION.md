# s25: NetworkPolicy — Solution

## Diagnosis

```bash
kubectl get netpol -A
kubectl describe netpol <name> -n <ns>
```

## Fix

**Create namespace-isolation policy:**
```bash
kubectl apply -f - << 'NETEOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ns-isolation
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector: {}
NETEOF
```

**Verify:**
```bash
kubectl get netpol
```

## Why

NetworkPolicy restricts traffic by label. Default-deny prevents all, then allow rules open specific paths.
