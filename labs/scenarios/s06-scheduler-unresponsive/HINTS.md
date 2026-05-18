# Hints for s06: Scheduler Unresponsive

## Symptoms
- Pods stuck in Pending
- Pod events show "no nodes match nodeSelector"
- No scheduling failures, just no matches

## Debugging Path
1. Check pod status: `kubectl describe pod <pending-pod>`
2. Look at events for the reason
3. Check node labels: `kubectl get nodes --show-labels`
4. Does any node have `node-type=compute` label?
5. Add label: `kubectl label node <name> node-type=compute`
6. Pods should transition to Running

## Key Commands
- `kubectl describe pod <name>` (shows pending reason in Events)
- `kubectl get nodes --show-labels`
- `kubectl label node <name> key=value`
