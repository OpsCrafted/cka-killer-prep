# Hints for s04: Service No Endpoints

## Symptoms
- Service exists but shows no ENDPOINTS
- Pods are Running but unreachable via service

## Debugging Path
1. Check service selector: `kubectl get svc backend -o yaml | grep selector`
2. Check pod labels: `kubectl get pods --show-labels`
3. They must match exactly (e.g., `app: backend` selector with `app: backend` label)
4. Fix Service spec or pod labels

## Key Commands
- `kubectl get svc` (shows ENDPOINTS column)
- `kubectl get pods --show-labels`
- `kubectl describe svc <name>`
