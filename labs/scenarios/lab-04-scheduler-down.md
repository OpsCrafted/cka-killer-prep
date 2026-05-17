# Lab 04: Scheduler Down

**Domain:** Architecture (25%) | **Difficulty:** Medium | **Time target:** 4 minutes

## Scenario
New pods are stuck in Pending state. No scheduling events appear. Something is wrong with the cluster's scheduling capability.

## Setup
```bash
./scripts/break.sh lab-04-scheduler-down
```

<details><summary>💡 Hint</summary>Check if all control plane components are running in kube-system.</details>

<details><summary>📖 Solution</summary>

```bash
kubectl -n kube-system get pods | grep scheduler
# No scheduler pod found

docker exec -it cka-lab-control-plane bash
ls /etc/kubernetes/manifests/
# kube-scheduler.yaml is missing!

# It was moved to the parent directory
mv /etc/kubernetes/kube-scheduler.yaml.bak /etc/kubernetes/manifests/kube-scheduler.yaml

# Wait for kubelet to recreate it
kubectl -n kube-system get pods | grep scheduler
```
</details>
