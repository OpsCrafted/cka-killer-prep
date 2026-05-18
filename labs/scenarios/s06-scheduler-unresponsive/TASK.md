# Scenario s06: Scheduler Can't Schedule Pods

## Problem

New pods are stuck in Pending state. The scheduler isn't picking them up. Check scheduler health.

## Expected State

- New pods transition from Pending → Running
- Scheduler logs show no errors
- Pods evenly distributed across nodes

## Time Limit

15 minutes
