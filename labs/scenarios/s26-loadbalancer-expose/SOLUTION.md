# s26: LoadBalancer — Solution

## Diagnosis

```bash
kubectl get svc -A
kubectl describe svc <name>
```

## Fix

**Create LoadBalancer service:**
```bash
kubectl apply -f - << 'LBEOF'
apiVersion: v1
kind: Service
metadata:
  name: app-lb
spec:
  type: LoadBalancer
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 8080
LBEOF
```

**Verify:**
```bash
kubectl get svc app-lb
```

## Why

LoadBalancer type exposes service externally. Requires external LB controller (cloud provider).
