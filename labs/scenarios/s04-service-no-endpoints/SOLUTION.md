# s04: Service Has No Endpoints — Solution

## Diagnosis Path

Service has no endpoints because its selector doesn't match any pod labels.

**Step 1:** Check service selector
```bash
kubectl get svc backend -o yaml | grep -A 5 selector
```

**Step 2:** Check pod labels
```bash
kubectl get pods --show-labels
# Does any pod have labels matching the selector?
```

**Step 3:** Fix by updating pod labels
```bash
kubectl label pod <pod-name> app=backend
# Add the missing label
```

**Step 4:** Verify endpoints appear
```bash
kubectl get svc backend
# ENDPOINTS should show pod IP:port
```

## Commands Used

```bash
kubectl get svc <name> -o yaml | grep -A 3 selector
kubectl get pods --show-labels
kubectl label pod <pod-name> app=backend
kubectl get svc <name>
kubectl get endpoints <name>
```

## Why This Fix Works

Endpoints controller matches service selectors against pod labels. When they match, controller adds pod IPs to Endpoints. Service then has targets to forward traffic to.

## Common Wrong Fixes

- **Restarting pods** — Labels don't change.
- **Recreating service** — Same broken selector.
- **Checking port instead of labels** — Port is usually OK; problem is label mismatch.
