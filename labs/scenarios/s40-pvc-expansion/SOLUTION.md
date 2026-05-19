# s40: PVC Expansion — Solution

## Diagnosis

```bash
kubectl get pvc
```

## Fix

**Enable expansion:**
```bash
kubectl patch storageclass <sc> -p '{"allowVolumeExpansion":true}'
```

**Expand PVC:**
```bash
kubectl patch pvc <name> -p '{"spec":{"resources":{"requests":{"storage":"20Gi"}}}}'
```

## Why

PVC can grow if StorageClass allows expansion. Only grows, not shrinks.
