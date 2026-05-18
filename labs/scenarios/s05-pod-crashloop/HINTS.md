# Hints for s05: Pod CrashLoopBackOff

## Symptoms
- Pod in CrashLoopBackOff state
- Restarts every few seconds
- Container logs show error

## Debugging Path
1. Check pod status: `kubectl describe pod <pod-name>`
2. Check logs: `kubectl logs <pod-name> --previous`
3. Look for: missing ConfigMap, missing Secret, wrong volumeMount, failed startup command
4. Create ConfigMap if missing: `kubectl create configmap app-config --from-literal=app.conf="..."`
5. Pod should stay Running

## Key Commands
- `kubectl describe pod <name>` (shows events and conditions)
- `kubectl logs <name> --previous` (logs before crash)
- `kubectl get configmap` (list ConfigMaps)
