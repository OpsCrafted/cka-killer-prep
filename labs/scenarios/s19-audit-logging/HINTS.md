# Hints for s19: Audit Logging

## Problem
API server audit logging not configured. No audit trail of API calls.

## Note
Audit logging is configured at the kube-apiserver level. In kind clusters, this requires recreating the control-plane pod, which is not typical for CKA exam scenarios.

## Understanding Audit Logging

Audit logging records API server activity for compliance and debugging.

## Configuration (typical cluster setup)

1. Create audit policy file (provided): `/tmp/audit-scenario/audit-policy.yaml`

2. Configure kube-apiserver flags:
   - `--audit-policy-file=/path/to/policy.yaml`
   - `--audit-log-path=/var/log/audit.log`
   - `--audit-log-max-age=30`
   - `--audit-log-max-backup=10`

3. Mount audit files in container

## Verification

```bash
kubectl get pod -n kube-system -l component=kube-apiserver -o yaml
# Look for: --audit-log-path and --audit-policy-file flags
```

## Key Concepts

- **Audit Policy**: Defines what events to log
- **Audit Levels**: None, Metadata, RequestResponse, Request
- **Log Format**: JSON

## Real-World Use

- Compliance (HIPAA, PCI-DSS, SOC2)
- Security investigation
- Troubleshooting
- Change tracking
