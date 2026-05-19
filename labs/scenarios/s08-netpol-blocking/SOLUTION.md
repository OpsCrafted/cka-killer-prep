# s08: NetworkPolicy Blocking Traffic — Solution

## Diagnosis Path

**Step 1:** Check NetworkPolicies
```bash
kubectl get networkpolicies
kubectl describe networkpolicy <name>
```

**Step 2:** Test connectivity
```bash
kubectl exec <pod> -- wget -O- http://service:port
# Times out
```

**Step 3:** Fix: add allow rule or delete policy
```bash
kubectl edit networkpolicy <name>
# Add ingress rule

# Or delete:
kubectl delete networkpolicy <name>
```

**Step 4:** Verify
```bash
kubectl exec <pod> -- wget -O- http://service:port
```

## Commands Used

```bash
kubectl get networkpolicies
kubectl describe networkpolicy <name>
kubectl exec <pod> -- wget -O- http://service:port
kubectl edit networkpolicy <name>
kubectl delete networkpolicy <name>
```

## Why This Fix Works

NetworkPolicy acts as firewall. Deny-all blocks traffic unless allow rules exist. Adding rule opens port.

## Common Wrong Fixes

- **Restarting pods** — Policy still applied.
- **Checking service instead of pod connectivity** — NetworkPolicy affects pods.
