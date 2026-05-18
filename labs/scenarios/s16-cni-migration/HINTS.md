# Hints for s16

Remove cni-pending taint:
\`\`\`bash
kubectl taint nodes --all cni-pending-
\`\`\`

Key: Know node taints block scheduling until CNI is ready.
