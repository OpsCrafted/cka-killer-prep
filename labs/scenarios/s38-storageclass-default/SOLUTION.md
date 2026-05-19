# s38: StorageClass Default — Solution

## Diagnosis

```bash
kubectl get storageclass
```

## Fix

**Create StorageClass:**
```bash
kubectl apply -f - << 'SCEOF'
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/no-provisioner
SCEOF
```

## Why

Default StorageClass auto-provisions PVs for PVCs.
