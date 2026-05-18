# Scenario s23: Ingress TLS - HTTPS routing with certs

## Problem
Ingress is configured but TLS certificate is missing or misconfigured. HTTPS traffic fails.

## Expected State
- TLS secret exists
- Ingress configured with tls section
- HTTPS traffic encrypted

## Time Limit
15 minutes
