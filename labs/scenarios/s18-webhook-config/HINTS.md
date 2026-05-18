# Hints for s18

List webhook configurations:
\`\`\`bash
kubectl get mutatingwebhookconfigurations
kubectl describe mutatingwebhookconfigurations <name>
\`\`\`

Fix broken webhook by deleting or updating it:
\`\`\`bash
kubectl delete mutatingwebhookconfigurations broken-webhook
\`\`\`

Key: Understand admission webhooks and their configuration.
