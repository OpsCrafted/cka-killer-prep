# Hints for s22: Backup Strategy

## Problem
No etcd backup exists. Cluster data is at risk.

## Solution
Backup etcd with etcdctl snapshot:

```bash
docker exec <CLUSTER>-control-plane \
  sh -c "ETCDCTL_API=3 etcdctl --endpoints=127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key \
    snapshot save /tmp/etcd-backup/backup.db"
```

Verify:
```bash
ls -la /tmp/etcd-backup/backup.db
```
