# s24: Gateway API — Solution

## Diagnosis

```bash
kubectl get gatewayclass
kubectl get gateway
kubectl get httproute
```

## Fix

**Create GatewayClass:**
```bash
kubectl apply -f - << 'GWEOF'
apiVersion: gateway.networking.k8s.io/v1beta1
kind: GatewayClass
metadata:
  name: demo-gateway
spec:
  controllerName: example.com/gateway-controller
GWEOF
```

**Verify:**
```bash
kubectl get gatewayclass
```

## Why

Gateway API requires controller acknowledgment. GatewayClass must exist first.
