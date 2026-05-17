# Lab 07: PVC Pending

## Scenario

A pod in the cluster is trying to mount a PersistentVolumeClaim called `data-pvc`. The PVC has been created but **is stuck in Pending state**. No PersistentVolume is bound to it.

The pod cannot start because its volume mount is not fulfilled.

## What's Broken

The PVC references a StorageClass by name, but the StorageClass **doesn't exist**, or the PVC selector doesn't match any available PVs.

## Your Task

1. **Diagnose** the PVC and check why it's Pending
2. **Check** what StorageClass it's looking for
3. **Verify** if that StorageClass exists
4. **Fix** either the PVC (change StorageClass name) or create the missing StorageClass
5. **Verify** the PVC binds to a PV and its status becomes Bound

## Commands to Get Started

```bash
kubectl get pvc
kubectl describe pvc data-pvc
kubectl get storageclass
kubectl get pv
kubectl edit pvc data-pvc
```

## What You Should See

After fixing, the PVC should transition to Bound and the pod should start Running.

## Solution Outline

- Find the StorageClass name in the PVC spec
- Check if that StorageClass exists
- If it doesn't exist, either create it or change the PVC's storageClassName to match an existing one
