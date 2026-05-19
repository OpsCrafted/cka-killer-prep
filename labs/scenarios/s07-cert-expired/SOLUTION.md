# s07: Certificate Expired — Solution

## Diagnosis Path

**Step 1:** Check cert expiration
```bash
docker exec <cluster>-control-plane kubeadm certs check-expiration
```

**Step 2:** Renew certs
```bash
docker exec <cluster>-control-plane kubeadm certs renew all
```

**Step 3:** Restart kubelet
```bash
docker exec <cluster>-control-plane systemctl restart kubelet
```

**Step 4:** Verify
```bash
kubectl cluster-info
kubectl get nodes
```

## Commands Used

```bash
docker exec <cluster>-control-plane kubeadm certs check-expiration
docker exec <cluster>-control-plane kubeadm certs renew all
docker exec <cluster>-control-plane systemctl restart kubelet
kubectl cluster-info
```

## Why This Fix Works

TLS certs expire. Renewing generates new ones. Restarting kubelet loads them.

## Common Wrong Fixes

- **Only checking** — Need to renew, not just check.
- **Not restarting kubelet** — New certs not loaded without restart.
