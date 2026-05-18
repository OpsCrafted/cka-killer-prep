# Scenario s16: CNI migration - network plugin swap

## Problem

Cluster needs to migrate from one CNI (Container Network Interface) plugin to another. Current CNI is broken; new one is ready but not active.

**Symptoms:**
- Pods pending or stuck with network errors
- Network plugin not recognized

## Expected State

- New CNI active and running
- All pods have IP addresses
- Pod-to-pod communication works

## Time Limit

15 minutes
