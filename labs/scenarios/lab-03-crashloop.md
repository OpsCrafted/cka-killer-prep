# Lab 03: CrashLoopBackOff

**Domain:** Troubleshooting (30%) | **Difficulty:** Medium | **Time target:** 4 minutes

## Scenario
Pod `app-server` in namespace `lab03` is in CrashLoopBackOff. The application team says it was working yesterday. Find out what's wrong and fix it.

## Setup
```bash
./scripts/break.sh lab-03-crashloop
```

<details><summary>💡 Hint</summary>Check the pod logs with `kubectl logs --previous`.</details>

<details><summary>📖 Solution</summary>

The pod tries to `cat /config/app.conf` which doesn't exist. Fix: either create a ConfigMap and mount it, or change the pod command to not require the file.

Simplest fix:
```bash
kubectl -n lab03 delete pod app-server
kubectl -n lab03 run app-server --image=busybox:1.36 --command -- sleep 3600
```
</details>
