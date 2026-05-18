# Hints for s12: Kubelet Misconfigured

## Symptoms
- Node shows NotReady or Unknown status
- Pods won't start on node
- kubelet is not running or crashing

## Debugging Path
1. Check node status: `kubectl get nodes`
2. SSH into worker: `docker exec <cluster>-worker bash`
3. Check kubelet status: `systemctl status kubelet`
4. Check kubelet logs: `journalctl -u kubelet -n 50`
5. Look for: "cannot find config file", "config not found"
6. Check kubelet config path: `cat /etc/sysconfig/kubelet` or `/etc/default/kubelet`
7. Fix config path to point to valid file
8. Restart: `systemctl restart kubelet`

## Key Commands
- `docker exec <node> systemctl status kubelet`
- `docker exec <node> journalctl -u kubelet -n 50`
- `docker exec <node> cat /etc/sysconfig/kubelet`
- `docker exec <node> systemctl restart kubelet`
