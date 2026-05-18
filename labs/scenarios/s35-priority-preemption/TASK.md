# Scenario s35: Priority and preemption - critical workload priority

## Problem
Critical workloads need higher priority to run before normal pods. PriorityClass not configured.

## Expected State
- PriorityClass created
- High-priority pods preempt lower-priority ones
- Critical workloads guaranteed scheduling

## Time Limit
15 minutes
