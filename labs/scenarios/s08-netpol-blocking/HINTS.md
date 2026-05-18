# Hints for s08: NetworkPolicy Blocking

## Symptoms
- Pods can't reach each other
- Connection timeouts between services
- NetworkPolicy denies traffic

## Debugging Path
1. Check NetworkPolicy: `kubectl get networkpolicies`
2. Describe it: `kubectl describe networkpolicy <name>`
3. Look for: policyTypes, ingress/egress rules, podSelector
4. Add allow rule or remove restrictive policy
5. Verify connectivity: `kubectl exec <pod> -- wget -O- http://service:port`

## Key Commands
- `kubectl get networkpolicies`
- `kubectl describe networkpolicy <name>`
- `kubectl edit networkpolicy <name>`
- `kubectl delete networkpolicy <name>`
