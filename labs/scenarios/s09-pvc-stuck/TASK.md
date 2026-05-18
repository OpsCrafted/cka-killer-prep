# Scenario s09: PersistentVolumeClaim Stuck in Pending

## Problem

A PersistentVolumeClaim (PVC) is stuck in Pending state. No PersistentVolume (PV) is binding to it.

Create or match a StorageClass so the PVC can bind to a PV.

## Expected State

- PVC status is Bound
- PV is created and Bound to PVC
- Pod can mount the volume

## Time Limit

15 minutes
