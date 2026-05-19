# s29: GatewayClass Binding — Solution

## Diagnosis

```bash
kubectl get gatewayclass
kubectl describe gatewayclass <name>
```

## Fix

**Create GatewayClass with controller:**
```bash
kubectl apply -f - << 'GCEOF'
apiVersion: gateway.networking.k8s.io/v1beta1
kind: GatewayClass
metadata:
  name: example-gc
spec:
  controllerName: example.com/gateway-controller
GCEOF
```

**Verify:**
```bash
kubectl get gatewayclass
```

## Why

GatewayClass links to controller. Controller acknowledges and manages Gateway resources.
