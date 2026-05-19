# s12: Kubelet Misconfigured — Solution

## Diagnosis

```bash
kubectl get nodes
docker exec <cluster>-worker journalctl -u kubelet -n 20
docker exec <cluster>-worker cat /etc/sysconfig/kubelet
```

## Fix

```bash
docker exec <cluster>-worker sed -i 's|wrong|correct|' /etc/sysconfig/kubelet
docker exec <cluster>-worker systemctl restart kubelet
```

## Why

kubelet needs valid config path.
