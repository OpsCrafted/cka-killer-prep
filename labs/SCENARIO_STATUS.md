# Scenario Status

Classification of all 40 CKA scenarios by implementation maturity.

## Status Levels

- **✓ Ready**: Full setup, meaningful verify, real tests pass
- **◐ Partial**: Setup exists, verify checks, but may need refinement
- **⊗ Draft**: Scenario defined, basic structure, setup/verify minimal or no-op

## By Status

### Ready (13 scenarios)
s01-s13: All troubleshooting scenarios fully implemented with realistic break/fix labs.
- Real setup: introduces meaningful failure/constraint
- Real verify: checks kubectl state, assertions on cluster condition
- Test coverage: setup mutates cluster, verify detects fixes

### Partial (7 scenarios)  
s14-s20: Cluster architecture scenarios have real verify checks but setup could be enhanced.
- s14: node-join - verify checks worker labels (✓ real)
- s15: runtime-switch - verify checks taints (✓ real)
- s16: cni-migration - verify checks taint state (✓ real)
- s17: custom-api - verify checks CRD (✓ real)
- s18: webhook-config - verify checks mutation webhook (✓ real)
- s19: audit-logging - verify basic check (✓ real)
- s20: rbac-design - verify checks RBAC role (✓ real)

### Draft (20 scenarios)
s21-s40: Scenario definitions exist (TASK.md), setup structure present, but verify is no-op.
- Setup: may be minimal or placeholder
- Verify: "echo ✓ PASSED" - not checking actual state
- Status: Ready for implementation but not production-ready

## Path to Publish-Ready

### Immediate (fix weak verifies)
- [ ] s11 (etcd-corruption): Enhance verify checks
- [ ] s01: Duplicate entry, clean up

### High-Value (complete s14-s20)
- [ ] Enhance setups with more realistic failure modes
- [ ] Add detailed verify assertions for each scenario
- [ ] Test all s14-s20 against real kind cluster

### Long-Term (implement s21-s40)
- [ ] Implement real setup/verify for each scenario
- [ ] Test against kind cluster
- [ ] Document expected outcomes

## Running Tests

```bash
# Test all scenarios
bash labs/test-all.sh

# This will:
# - Setup each scenario
# - Run verify
# - Report pass/fail
# - Only Ready scenarios should pass verify
# - Partial/Draft scenarios may pass but verify is incomplete
```

## CI Validation

CI detects:
- Placeholder text in TASK.md
- No-op setup/verify
- Weak verify scripts
- Shell syntax errors

Currently passes all checks, but s21-s40 no-op verifies still pass CI.
