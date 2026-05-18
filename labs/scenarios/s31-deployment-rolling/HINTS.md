# Hints for s31: Deployment Rolling Update

## Problem
Deployment `web-app` has a rolling update strategy that causes downtime.

Current config: `maxSurge: 0`, `maxUnavailable: 1` (one pod down at a time = downtime)

## Solution
Update strategy to enable zero-downtime rolling updates:

```bash
kubectl patch deployment web-app -n rollout-test \
  --type='json' -p='[
    {"op": "replace", "path": "/spec/strategy/rollingUpdate/maxSurge", "value": 1},
    {"op": "replace", "path": "/spec/strategy/rollingUpdate/maxUnavailable", "value": 0}
  ]'
```

Or edit directly:
```bash
kubectl edit deployment web-app -n rollout-test
```

Set in spec.strategy.rollingUpdate:
```yaml
maxSurge: 1
maxUnavailable: 0
```

## Verification
```bash
kubectl get deployment web-app -n rollout-test -o jsonpath='{.spec.strategy.rollingUpdate}'
```

## Key Concepts
- `maxSurge` > 0: allows temporary pods above replicas count
- `maxUnavailable` = 0: zero pods can be down (true zero-downtime)
- For rolling updates: need both maxSurge and tight maxUnavailable
