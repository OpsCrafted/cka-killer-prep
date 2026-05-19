# s03: CoreDNS Pod Crash Loop — Solution

## Diagnosis Path

CoreDNS ConfigMap has a syntax error: a `loop` directive that causes infinite recursion. This breaks DNS resolution cluster-wide.

**Step 1:** Identify the problem
```bash
kubectl get pods -n kube-system -l k8s-app=kube-dns
# Shows coredns pods in CrashLoopBackOff
```

**Step 2:** Check CoreDNS pod logs
```bash
kubectl logs <coredns-pod> -n kube-system --tail=20
# Look for errors about Corefile syntax or loop detection
```

**Step 3:** Inspect the CoreDNS ConfigMap
```bash
kubectl get configmap coredns -n kube-system -o yaml
# Look for "loop" directive in Corefile data
```

**Step 4:** Remove the broken directive
```bash
kubectl edit configmap coredns -n kube-system
# Find the line with "loop" and delete it
# Save and exit (vim: :wq)
```

**Step 5:** Restart CoreDNS deployment to pick up new config
```bash
kubectl rollout restart deployment/coredns -n kube-system
kubectl get pods -n kube-system -l k8s-app=kube-dns --watch
# Wait for new pods to show Running
```

**Step 6:** Verify DNS works
```bash
kubectl exec <test-pod> -- nslookup kubernetes.default
# Should return 10.96.0.1 (cluster IP of kubernetes service)
```

## Commands Used

```bash
# Diagnose
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl logs -n kube-system <pod-name> --tail=30
kubectl get configmap coredns -n kube-system -o yaml | grep -A 30 Corefile

# Fix
kubectl edit configmap coredns -n kube-system
# Remove the "loop" line

# Restart
kubectl rollout restart deployment/coredns -n kube-system

# Verify
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl exec <test-pod> -- nslookup kubernetes.default
```

## Why This Fix Works

The CoreDNS `loop` plugin detects infinite forward loops and crashes. Removing this line lets DNS work normally. Restarting the deployment forces all pods to read the updated ConfigMap.

## Common Wrong Fixes

- **Restarting pods without fixing ConfigMap** — Pods crash again immediately.
- **Deleting coredns pods manually** — ConfigMap still broken; pods restart in CrashLoop.
- **Trying to edit the pod spec** — ConfigMap is what matters, not pod spec.
- **Removing other directives** — Only remove `loop`; keep health, ready, kubernetes, forward, cache.
- **Not restarting deployment** — Existing pods won't see the new config.
