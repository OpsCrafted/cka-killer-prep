# Hints for s03: CoreDNS Broken

## Symptoms

- CoreDNS pod in CrashLoopBackOff
- Pods can't resolve service names
- nslookup fails inside pods

## Debugging Path

1. **Check CoreDNS pod status:**
   ```
   kubectl get pods -n kube-system -l k8s-app=kube-dns
   kubectl describe pod <coredns-pod> -n kube-system
   kubectl logs <coredns-pod> -n kube-system
   ```

2. **Check CoreDNS ConfigMap:**
   ```
   kubectl get configmap coredns -n kube-system -o yaml
   ```

3. **Likely issue: Invalid Corefile syntax**
   - Look for `loop` directive (causes infinite recursion)
   - Check for duplicate directives

4. **Fix ConfigMap and restart:**
   ```
   kubectl edit configmap coredns -n kube-system
   # Remove the "loop" line, save
   kubectl rollout restart deployment/coredns -n kube-system
   ```

## Key Commands

- `kubectl get pods -n kube-system -l k8s-app=kube-dns`
- `kubectl logs -f <pod> -n kube-system | head -20`
- `kubectl exec <test-pod> -- nslookup kubernetes.default`
