# s10: RBAC Forbidden — Solution

## Diagnosis

**Check logs:**
```bash
kubectl logs <pod>
```

**Check perms:**
```bash
kubectl get roles
kubectl get rolebindings
```

**Create role + binding:**
```bash
kubectl create role app-reader --verb=get,list --resource=configmaps
kubectl create rolebinding app-reader-bind --role=app-reader --serviceaccount=default:app-reader
```

## Why

ServiceAccount without Role = Forbidden. Add Role with permissions.
