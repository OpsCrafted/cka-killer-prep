# s31: Deployment Rolling Update — Solution

## Diagnosis

```bash
kubectl get deployment
kubectl get pods -o wide
kubectl describe deployment <name>
```

## Fix

**Update image:**
```bash
kubectl set image deployment/<name> <container>=<new-image>
```

**Monitor rollout:**
```bash
kubectl rollout status deployment/<name>
```

**Verify:**
```bash
kubectl get pods
kubectl describe pod <name> | grep Image
```

## Why

Rolling update replaces old pods with new ones gradually. No downtime.

## Mistakes

- Not checking rollout status
- Wrong image name
