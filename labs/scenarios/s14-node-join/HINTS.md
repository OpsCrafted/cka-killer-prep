# Hints for s14: Node join

## Diagnosis

```bash
kubectl get nodes
# Look for any node without "worker" in the ROLES column
```

The node is missing the `node-role.kubernetes.io/worker` label.

## Solution

Add the worker label to the new node:

```bash
# Option A: Using kubectl label
kubectl label node <node-name> node-role.kubernetes.io/worker=

# Option B: Edit the node
kubectl edit node <node-name>
# Add to spec.metadata.labels:
#   node-role.kubernetes.io/worker: ""
```

## Key Concepts

- **Node labels**: Kubernetes uses labels to identify node roles
- **Standard labels**: `node-role.kubernetes.io/control-plane=`, `node-role.kubernetes.io/worker=`
- **kubeadm**: Automatically labels nodes, but manual labeling is sometimes needed
- **RBAC**: Some policies target specific node roles via labels

## Commands

```bash
kubectl get nodes
kubectl get nodes -L node-role.kubernetes.io/worker
kubectl label node <name> key=value
kubectl label node <name> key- # Remove label
```
