# Scenario s40: PVC expansion - grow persistent volume

## Problem
PVC needs to be expanded but resize not working. StorageClass doesn't allow expansion.

## Expected State
- StorageClass allowVolumeExpansion enabled
- PVC can be resized
- Expanded capacity available to pod

## Time Limit
10 minutes
