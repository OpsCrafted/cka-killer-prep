# Scenario s14: Node join - kubeadm bootstrap

## Problem

A new worker node has been provisioned and is running kubelet, but hasn't been labeled as a worker node. The node appears in `kubectl get nodes` but is missing the proper role label that identifies it as a worker.

**Symptoms:**
- Node shows in cluster but labeled "control-plane" or with generic label
- Pod scheduling may prefer control-plane over actual workers
- RBAC roles targeting workers don't apply to this node

## Expected State

Node properly labeled as worker:
- `kubectl get nodes` shows node with "worker" role
- Node has `node-role.kubernetes.io/worker=` label
- Pods can be scheduled to node following normal affinity rules

## Time Limit

5 minutes

## Exam Notes

- Use `kubectl label` or edit node YAML
- Understand Kubernetes node roles and labels
- Know the standard label keys for node roles
