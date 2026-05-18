# Hints for s20: RBAC Design

## Problem
The pod `app-reader` in the `rbac-test` namespace is trying to read a secret but doesn't have permissions.

## Solution
Create a Role that allows reading secrets, then bind it to the service account:

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

## Verification
Check pod logs to confirm it can now read the secret:
```bash
kubectl logs app-reader -n rbac-test
```

Key: Understand how Roles define permissions and RoleBindings connect them to service accounts.
