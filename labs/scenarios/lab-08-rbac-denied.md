# Lab 08: RBAC Denied

## Scenario

A pod named `app` in the `default` namespace needs to read pod information from the Kubernetes API. The ServiceAccount exists and is correctly mounted into the pod, but **the RBAC permissions are missing**.

The pod attempts to list pods in its namespace and gets a 403 Forbidden error.

## What's Broken

The ServiceAccount `app` exists and is mounted in the pod, but there is **no RoleBinding** granting it permissions. The pod has no access to the Kubernetes API.

## Your Task

1. **Diagnose** the RBAC setup for the `app` ServiceAccount
2. **Check** if a Role exists that grants `list pods` permission
3. **Verify** if a RoleBinding connects the Role to the ServiceAccount
4. **Create** the missing RoleBinding to grant the Role to the ServiceAccount
5. **Verify** the pod can now list pods via the API

## Commands to Get Started

```bash
kubectl get serviceaccount app
kubectl get role
kubectl get rolebinding
kubectl auth can-i list pods --as=system:serviceaccount:default:app
kubectl create rolebinding app-list-pods \
  --role=<role-name> \
  --serviceaccount=default:app
```

## What You Should See

Before fix: `kubectl auth can-i list pods --as=system:serviceaccount:default:app` returns `no`
After fix: It returns `yes`

## Solution Outline

1. Find a Role that grants `verbs: [list, get]` on `resources: [pods]`
2. Create a RoleBinding to connect the Role to the ServiceAccount
3. Verify with `kubectl auth can-i`
