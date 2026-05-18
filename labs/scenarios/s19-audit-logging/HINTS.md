# Hints for s19

Audit logging is configured at the kube-apiserver level via flags:
- \`--audit-log-path\` - path to audit log
- \`--audit-policy-file\` - policy defining what to log

For kind clusters, check:
\`\`\`bash
kubectl get pods -n kube-system -l component=kube-apiserver
kubectl describe pod -n kube-system <apiserver-pod>
\`\`\`

Key: Understand API server audit logging configuration.
