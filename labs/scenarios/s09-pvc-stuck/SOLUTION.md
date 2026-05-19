# s09: PVC Stuck Pending — Solution

## Diagnosis

**Check PVC:**
```bash
kubectl describe pvc <name>
```

**Check StorageClass:**
```bash
kubectl get storageclass
# Does it exist?
```

**Create StorageClass:**
```bash
kubectl create storageclass premium-storage --provisioner=kubernetes.io/no-provisioner
```

**Update PVC:**
```bash
kubectl edit pvc <name>
# Fix storageClassName
```

**Verify:**
```bash
kubectl get pvc
# Bound
```

## Why

PVC needs StorageClass to bind to PV. Missing = stuck.

## Common Mistakes

- Creating manual PV instead
- Wrong provisioner
