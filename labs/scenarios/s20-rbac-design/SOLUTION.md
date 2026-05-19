# s20: RBAC Design — Solution

## Diagnosis Path

Pod permission denied: ServiceAccount lacks RBAC permissions.

**Check logs:**
```bash
kubectl logs app-reader -n rbac-test
# Look for "Forbidden"
```

**Check ServiceAccount:**
```bash
kubectl describe sa app-sa -n rbac-test
```

**Check Role/RoleBinding:**
```bash
kubectl get role,rolebinding -n rbac-test
```

## Fix

**Create Role + RoleBinding:**
```bash
kubectl apply -f - << 'RBAC'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-reader
  namespace: rbac-test
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-reader
  namespace: rbac-test
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: app-reader
subjects:
- kind: ServiceAccount
  name: app-sa
  namespace: rbac-test
RBAC
```

## Verify

```bash
kubectl logs app-reader -n rbac-test
# Should show success

kubectl auth can-i get secrets --as=system:serviceaccount:rbac-test:app-sa
# Should allow
```

## Why

Role defines permissions. RoleBinding connects Role to ServiceAccount. Both needed: one without other = forbidden.

## Common Mistakes

- Role without RoleBinding — permissions exist but not attached
- ClusterRole instead of Role — global instead of namespace
- Wrong apiGroup ("v1" not "") — doesn't match resource
- Wrong verbs (list not get) — can list but not read
- Binding to wrong SA — permissions granted to different account
