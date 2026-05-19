# s27: DNS Debugging — Solution

## Diagnosis

```bash
kubectl get svc -n kube-system -l k8s-app=kube-dns
kubectl logs -n kube-system <dns-pod>
```

## Fix

**Check CoreDNS ConfigMap:**
```bash
kubectl get configmap coredns -n kube-system -o yaml | grep -A 20 Corefile
```

**Fix config and restart:**
```bash
kubectl rollout restart deployment/coredns -n kube-system
```

**Verify DNS:**
```bash
kubectl exec <pod> -- nslookup kubernetes.default
```

## Why

DNS pod may crash or ConfigMap broken. Restart forces reload.
