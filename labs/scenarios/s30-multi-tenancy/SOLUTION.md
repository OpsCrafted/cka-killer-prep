# s30: Multi-Tenancy — Solution

## Diagnosis

```bash
kubectl get namespace
kubectl get rolebinding -A
```

## Fix

**Create tenant namespaces:**
```bash
kubectl create namespace tenant-a
kubectl create namespace tenant-b
```

**Create tenant ServiceAccounts:**
```bash
kubectl create sa tenant-a-admin -n tenant-a
kubectl create sa tenant-b-admin -n tenant-b
```

**Create RBAC bindings:**
```bash
kubectl create rolebinding admin -n tenant-a --clusterrole=admin --serviceaccount=tenant-a:tenant-a-admin
kubectl create rolebinding admin -n tenant-b --clusterrole=admin --serviceaccount=tenant-b:tenant-b-admin
```

## Why

Multi-tenancy requires namespace isolation + RBAC per tenant.
