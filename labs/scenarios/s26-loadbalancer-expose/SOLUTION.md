# s26: LoadBalancer — Solution

## Diagnosis

Check service type:
```bash
kubectl get svc app-lb -n lb-test
kubectl describe svc app-lb -n lb-test
# Service type: ClusterIP (should be LoadBalancer)
```

## Fix

Patch service type to LoadBalancer:
```bash
kubectl patch service app-lb -n lb-test -p '{"spec":{"type":"LoadBalancer"}}'
```

Or recreate with correct type:
```bash
kubectl delete service app-lb -n lb-test
kubectl expose deployment app -n lb-test --type=LoadBalancer --port=80 --name=app-lb
```

Verify external IP assigned (may be pending in kind):
```bash
kubectl get svc app-lb -n lb-test
# EXTERNAL-IP: <pending> or actual IP (depends on LB controller)
```

## Why

Service needs LoadBalancer type for external exposure. ClusterIP only works within cluster.

## Key Points

- ClusterIP: internal only
- NodePort: external on node IPs (31000+ port range)
- LoadBalancer: external via cloud LB (or pending in local cluster)
