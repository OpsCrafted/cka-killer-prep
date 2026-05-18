# Hints for s07: Certificate Expired

## Symptoms
- "certificate has expired" errors
- API server connection issues
- Component-to-component authentication failures

## Debugging Path
1. Check cert expiration: `docker exec <cluster>-control-plane kubeadm certs check-expiration`
2. Look for RED WARNINGS in output (expired or expiring soon)
3. If expired, renew: `docker exec <cluster>-control-plane kubeadm certs renew all`
4. Restart components: `systemctl restart kubelet`
5. Verify API is responding: `kubectl cluster-info`

## Key Commands
- `docker exec <cluster>-control-plane kubeadm certs check-expiration`
- `docker exec <cluster>-control-plane kubeadm certs renew <cert-name>`
- `kubectl cluster-info`
