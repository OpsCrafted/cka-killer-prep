# Lab 09: etcd Restore

## Scenario

A namespace `production` was accidentally deleted. The pods, deployments, and other resources in that namespace are gone. However, you have a backup snapshot of etcd from before the deletion.

You need to **restore etcd from the snapshot** to recover the deleted resources.

## What's Broken

The `production` namespace and all its resources have been deleted from etcd. The etcd process itself is running fine, but the data has changed. You must restore from an etcd snapshot (backup) to get the data back.

## Your Task

1. **SSH to the control plane node**
2. **Stop the Kubernetes API server and kubelet** (so they don't interfere with the restore)
3. **Restore etcd from the snapshot** using `etcdctl snapshot restore`
4. **Replace the etcd data directory** with the restored backup
5. **Restart the API server and kubelet**
6. **Verify** the `production` namespace and its resources are back

## Commands to Get Started

```bash
ssh <control-plane-ip>
sudo systemctl stop kubelet
sudo etcdctl snapshot restore /var/backups/etcd-backup.db \
  --data-dir=/var/lib/etcd-restore \
  --initial-cluster=master=https://127.0.0.1:2380
sudo rm -rf /var/lib/etcd
sudo mv /var/lib/etcd-restore /var/lib/etcd
sudo systemctl start kubelet
```

## What You Should See

Before restore: `kubectl get ns | grep production` shows nothing
After restore: The production namespace and its pods are back

## Important Notes

- Restore is destructive: it replaces the entire etcd data
- Any changes made after the snapshot was taken will be lost
- You need sudo privileges

## Solution Outline

1. Stop the API server to avoid conflicts
2. Use `etcdctl snapshot restore` to hydrate a new etcd directory from the backup
3. Swap the old etcd data with the restored data
4. Restart services
5. Verify with `kubectl` commands
