# Contributing to CKA Killer Prep

Want to improve the course? All contributions welcome: scenarios, fixes, docs.

## Adding a Scenario

1. **Check existing s01-s40** to understand patterns
2. **Create directory** `labs/scenarios/sXX-scenario-name/`
3. **Implement 5 files:**
   - `TASK.md`: Problem description (20-30 lines)
   - `setup.sh`: Break cluster state (must fail setup on CLI errors)
   - `verify.sh`: Check if fixed (must return 0 on fixed, 1 on broken)
   - `reset.sh`: Clean up (resets cluster for retry)
   - `HINTS.md`: Debugging tips & kubectl commands
4. **Test locally:**
   ```bash
   bash labs/test-all.sh setup      # Verify setup works
   bash labs/test-all.sh contract   # Verify breaks on unbroken state
   ```
5. **Update** `labs/SCENARIO_STATUS.md` with new scenario
6. **Submit PR** with description of what scenario teaches

## Scenario Guidelines

### TASK.md
- Describe the problem (what's broken)
- List symptoms (what user will observe)
- State expected outcome (what "fixed" looks like)
- Time estimate (usually 10-15 min)

### setup.sh
- Must introduce a real failure condition
- Use `set -e` to fail on errors
- Create resources in namespace (not default)
- Print "✓ Scenario setup complete" at end
- Example: stop API server, taint node, create broken config

### verify.sh
- Check actual Kubernetes state (not just resource existence)
- Use `kubectl get`, `jq`, comparisons
- Print `✗ FAILED: <reason>` and exit 1 on failure
- Print `✓ PASSED: <result>` and exit 0 on success
- Must fail if setup was just run (user hasn't fixed yet)

### reset.sh
- Undo setup.sh changes
- Restart broken services
- Delete test namespaces
- Usually just deletes namespace or restarts services

### HINTS.md
- 1-2 key debugging commands
- 1 common mistake
- 1 reference link
- Keep it short (10-15 lines)

## Testing

```bash
# Single scenario
cd labs && bash run.sh 01              # setup
bash run.sh verify 01                  # verify
bash run.sh reset 01                   # cleanup

# All scenarios
bash test-all.sh setup                 # all 40 setup (verifies setup works)
bash test-all.sh contract              # all 40 setup + contract (verifies verify detects broken state)

# CI will run before merge
# Check: no placeholder TODOs, shell syntax, verify scripts exist
```

## Code Quality

- No TODOs or FIXMEs in TASK.md
- Shell scripts must pass `bash -n` syntax check
- Scenario must work on kind cluster (not production-only)
- Verify script must fail on broken state
- Keep setup.sh under 60 lines (if >80, split into 2 scenarios)

## Reporting Issues

Found a broken scenario?
1. Note which scenario (s01, s15, etc)
2. What you expected vs what happened
3. kubectl/docker/kind version

## Structure

```
labs/scenarios/sXX-scenario-name/
├── TASK.md           (problem description)
├── setup.sh          (introduce failure)
├── verify.sh         (check if fixed)
├── reset.sh          (cleanup)
├── HINTS.md          (debugging tips)
└── manifests/        (optional: YAML files used by setup.sh)
    └── deployment.yaml
```

## Questions?

- Read existing scenarios s01-s20 (all Ready, good examples)
- Check SCENARIO_STATUS.md for patterns
- Open an issue with questions

Thanks for contributing!
