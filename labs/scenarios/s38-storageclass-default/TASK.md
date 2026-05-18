# Scenario s38: StorageClass - default storage configuration

## Problem
StorageClass not set as default. PVCs fail to provision without explicit StorageClass reference.

## Expected State
- StorageClass marked as default
- PVCs use default StorageClass
- Dynamic provisioning works without explicit reference

## Time Limit
10 minutes
