# s31: Deployment Rolling Update — Solution

## Diagnosis

Check rolling update strategy:
```bash
kubectl get deployment web-app -n rollout-test -o jsonpath='{.spec.strategy.rollingUpdate}'
# maxSurge: 0, maxUnavailable: 1 (causes downtime!)
```

Check pod status during updates:
```bash
kubectl get pods -n rollout-test -w
# With current strategy: pods go down one at a time
```

## Fix

Patch deployment with zero-downtime rolling strategy:
```bash
kubectl patch deployment web-app -n rollout-test -p '{"spec":{"strategy":{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0}}}}'
```

Verify strategy is fixed:
```bash
kubectl get deployment web-app -n rollout-test -o jsonpath='{.spec.strategy.rollingUpdate}'
# Should show: maxSurge: 1, maxUnavailable: 0
```

## Why

Rolling update strategy controls how pods are replaced:
- **maxSurge**: extra pods allowed during update (speeds up, uses more resources)
- **maxUnavailable**: pods allowed to be down (setting to 0 = zero downtime)

Current settings (0, 1) = 1 pod down at a time = downtime during updates.
Fixed settings (1, 0) = 1 new pod up, old pod removed = zero downtime.

## Zero-Downtime Best Practice

Always use: `maxSurge > 0` AND `maxUnavailable = 0`
