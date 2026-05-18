# Scenario s02: Worker Node Not Ready

## Problem

One of your worker nodes has gone NotReady. Pods on that node are evicted, and new pods won't schedule there.

Diagnose the issue and bring the node back to Ready state.

## Expected State

- All nodes report Ready status
- No NotReady, NotSchedulable, or MemoryPressure conditions
- Kubelet is running and responsive

## Time Limit

15 minutes
