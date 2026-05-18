# Hints for s10: RBAC Forbidden

## Symptoms
- Pod logs show "Forbidden" (403) errors
- ServiceAccount exists but has no permissions
- API calls fail with "forbidden"

## Debugging Path
1. Check pod logs: `kubectl logs <pod-name>`
2. Look for "Forbidden" or "forbidden"
3. Check ServiceAccount: `kubectl describe sa app-reader`
4. Check Roles: `kubectl get roles`
5. Check RoleBindings: `kubectl get rolebindings`
6. Create Role and RoleBinding:
   ```
   kubectl create role app-reader --verb=get,list,watch --resource=configmaps
   kubectl create rolebinding app-reader-binding --role=app-reader --serviceaccount=default:app-reader
   ```

## Key Commands
- `kubectl logs <pod>`
- `kubectl describe sa <name>`
- `kubectl get roles`
- `kubectl get rolebindings`
- `kubectl describe rolebinding <name>`
