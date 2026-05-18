# Scenario s32: StatefulSet - persistent pod identity

## Problem
StatefulSet pods losing identity or persistent storage not bound. VolumeClaimTemplate misconfigured.

## Expected State
- StatefulSet pods have stable identity
- Persistent storage bound to pods
- Pod restarts keep same identity

## Time Limit
15 minutes
