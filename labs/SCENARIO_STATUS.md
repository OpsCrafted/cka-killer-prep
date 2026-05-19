# Scenario Status

Classification of all 40 CKA scenarios by implementation maturity.

## Status Levels

- **✓ Ready**: Full setup, meaningful verify, real tests pass
- **◐ Partial**: Setup exists, verify checks, but may need refinement
- **⊗ Draft**: Scenario defined, basic structure, setup/verify minimal or no-op

## By Status

### Ready (20 scenarios)
s01-s20: All troubleshooting and cluster architecture scenarios fully implemented with realistic break/fix labs.
- **s01-s13**: Troubleshooting scenarios with pod/node/service failures
- **s14-s20**: Cluster architecture scenarios with node/runtime/networking/API/webhook/RBAC configuration
- Real setup: introduces meaningful failure/constraint
- Real verify: checks kubectl state, assertions on cluster condition
- Test coverage: setup mutates cluster, verify detects fixes
- Constraints enforced: RBAC pod cannot read secret without role (s20), etcd restore validates backup usage (s11)

### Partial (20 scenarios)
s21-s40: All scenarios have real setup scripts that create failure conditions. Verify scripts now have real assertions for all 40 scenarios.
- **s21-s22**: RBAC and backup scenarios with real failure states
- **s23-s30**: Networking scenarios (Ingress, Gateway API, NetworkPolicy, LoadBalancer, DNS, ServiceDiscovery)
- **s31-s36**: Workload scenarios (Deployments, StatefulSets, HPA, ResourceLimits, Affinity, Priority)
- **s37-s40**: Storage scenarios (PV/PVC binding, StorageClass, LocalStorage, PVC Expansion)
- Real setup: introduces meaningful failure/constraint in all scenarios
- Verify: checks appropriate resources exist and are configured
- Status: All scenarios functional, verify scripts cover core validation logic

## Path to Publish-Ready

### Completed ✓
- [x] s01-s20: Full implementation with real failure enforcement
- [x] s21-s40: Basic implementation with real setup/verify (no longer no-op)
- [x] s11, s20: Enhanced weak verifies with constraint validation
- [x] All 40 scenarios have meaningful setup and verification

### Remaining (refinement)
- [x] s21-s40: Enhance verify scripts with real assertions (✓ completed)
- [x] Test all s01-s40 against real kind cluster (✓ all 40 pass)
- [ ] Document expected user workflows for each scenario
- [ ] Run `test-all.sh contract` mode to ensure verify contracts hold

## Running Tests

```bash
# Setup-only mode (default) - verify that setup scripts work
bash labs/test-all.sh setup
# or simply: bash labs/test-all.sh

# Contract mode - verify that setup works AND verify.sh detects broken state
bash labs/test-all.sh contract

# Single scenario
cd labs && bash run.sh 01  # setup s01
bash run.sh verify 01     # verify s01
bash run.sh reset 01      # reset s01
```

## CI Validation

CI detects:
- Placeholder text in TASK.md
- No-op setup/verify
- Weak verify scripts
- Shell syntax errors

All scenarios now pass CI validation with real setup/verify logic.
