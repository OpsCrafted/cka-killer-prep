# Scenario s13: Rolling upgrade across nodes

## Problem

One worker node needs to be upgraded. A deployment is running pods across all three nodes, but one node is cordoned to prevent new scheduling. Pods are stranded on the cordoned node.

**Symptoms:**
- `kubectl get nodes` shows one node with status "SchedulingDisabled" (cordoned)
- Deployment shows desired replicas not matching ready replicas
- `kubectl describe node <cordoned>` shows Taints with "NoSchedule"

## Expected State

All pods running, ready for node upgrade:
- All worker nodes have status "Ready"
- No nodes cordoned
- Deployment: all pods Running and Ready (2/2)
- Nodes can accept new pod scheduling

## Time Limit

10 minutes

## Exam Notes

- Use `kubectl cordon/uncordon` or node YAML editing
- Understand node taints vs cordoning
- Do NOT delete pods manually (they reschedule with wrong node affinity)
