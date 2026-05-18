# Scenario s18: Webhook config - mutating admission controller

## Problem

Mutating webhook is defined but not properly registered. Webhook server is running but API server isn't calling it.

**Symptoms:**
- Webhook rules not being enforced
- MutatingWebhookConfiguration exists but inactive
- Pods created without expected mutations

## Expected State

- MutatingWebhookConfiguration active
- API server calling webhook correctly
- Mutations being applied to new objects

## Time Limit

15 minutes
