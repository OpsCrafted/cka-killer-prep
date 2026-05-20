# s33: Resource Limits — Solution

## Diagnosis

Check current pod resources:
```bash
kubectl describe pod app-pod -n resource-test
# Shows: Limits (cpu, memory) but NO Requests
```

Check container spec:
```bash
kubectl get pod app-pod -n resource-test -o jsonpath='{.spec.containers[0].resources}'
# Only has: limits, missing: requests
```

## Fix

Delete pod and recreate with requests:
```bash
kubectl delete pod app-pod -n resource-test

kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  namespace: resource-test
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:
        cpu: "50m"
        memory: "64Mi"
      limits:
        cpu: "100m"
        memory: "128Mi"
EOF
```

Verify both requests and limits exist:
```bash
kubectl get pod app-pod -n resource-test -o jsonpath='{.spec.containers[0].resources}'
# Should have both requests and limits
```

## Why

- **Requests**: guarantee minimum resources for pod scheduling + operation
- **Limits**: prevent pod from consuming too many resources
- Both needed: requests for scheduler, limits for stability

## Key Points

- Requests < Limits always
- Requests affect node scheduling decisions
- Limits enforce hard caps via cgroup
