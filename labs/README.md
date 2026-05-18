# CKA Labs — 40 Hands-On Scenarios

40 practical Kubernetes scenarios organized by CKA exam domain weights. One command builds & launches each lab.

## Quick Start

```bash
cd labs
./run.sh 01
```

Done. Cluster builds, scenario starts, you fix it.

## Requirements

**All Platforms (macOS / Linux / Windows):**

- Docker Desktop
- kind
- kubectl
- Git Bash (Windows) or WSL2

### Install

**macOS:**

```bash
brew install docker kind kubectl
```

**Linux (Ubuntu/Debian):**

```bash
curl -fsSL https://get.docker.com | sh
curl -Lo kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x kind && sudo mv kind /usr/local/bin/
sudo apt-get install -y kubectl
```

**Windows (Git Bash / WSL):**

```powershell
choco install docker-desktop kind kubectl
# Then: git bash> ./run.sh 01
```

## Workflow

### Single Scenario
```bash
./run.sh 01                    # Start scenario 01 (setup breaks state)
# Diagnose & fix with kubectl
./run.sh verify 01             # Check if fixed correctly
./run.sh reset 01              # Clean and retry
./run.sh clean                 # Delete cluster
```

### Batch Testing
```bash
# Test setup only (verify scripts run after setup works)
bash test-all.sh setup
# or: bash test-all.sh

# Test setup + verify (verifies that setup breaks state properly)
bash test-all.sh verify
```

## Scenario Status

**Ready (20 scenarios):** s01-s20 — Full implementation, setup breaks state, verify checks fix
- Troubleshooting (s01-s13): Real failures (api-server down, node crashed, dns broken, etc)
- Cluster Architecture (s14-s20): Node/runtime/network/webhook/RBAC config issues

**Partial (20 scenarios):** s21-s40 — Real setup, verify checks resources exist
- s21-s22: RBAC, backups
- s23-s30: Networking (Ingress, Gateway, NetworkPolicy, LoadBalancer, etc)
- s31-s36: Workloads (Deployments, StatefulSets, HPA, scheduling)
- s37-s40: Storage (PV/PVC, StorageClass, local storage)

## All Scenarios

### See List

```bash
./run.sh list
```

### By Domain

**Troubleshooting (30%) — 12 scenarios:**
s01 (api-server), s02 (node-ready), s03 (coredns), s04 (service), s05 (crashloop), s06 (scheduler), s07 (cert), s08 (netpol), s09 (pvc), s10 (rbac), s11 (etcd), s12 (kubelet)

**Cluster Arch (25%) — 10 scenarios:**
s13 (upgrade), s14 (join), s15 (runtime), s16 (cni), s17 (crd), s18 (webhook), s19 (audit), s20 (rbac), s21 (sa), s22 (backup)

**Networking (20%) — 8 scenarios:**
s23 (ingress-tls), s24 (gateway), s25 (netpol), s26 (lb), s27 (dns), s28 (discovery), s29 (class), s30 (multi)

**Workloads (15%) — 6 scenarios:**
s31 (rolling), s32 (stateful), s33 (limits), s34 (affinity), s35 (priority), s36 (hpa)

**Storage (10%) — 4 scenarios:**
s37 (pv-pvc), s38 (storageclass), s39 (local), s40 (expand)

## Scenario Structure

Each scenario contains:

- **TASK.md** — Problem description
- **setup.sh** — Introduce failure
- **verify.sh** — Check solution
- **reset.sh** — Cleanup
- **HINTS.md** — Tips & commands

## Quick Commands

```bash
k get nodes
k get pods -A
k describe node <name>
k logs <pod> -n <ns>
k exec -it <pod> -n <ns> -- bash
```

## Tips

- Read TASK.md fully before diagnosing
- Use `describe` before `logs`
- Check node status via `docker exec` into node
- Time yourself (avg 10-15 min per scenario)
- Review hints only after attempting

## SSH into Nodes

```bash
docker exec -it cka-lab-control-plane bash
docker exec -it cka-lab-worker bash
docker exec -it cka-lab-worker2 bash
```

## Reference

- [Kubernetes Docs](https://kubernetes.io/docs)
- [CKA Exam](https://www.cncf.io/certification/cka/)
- [kind Docs](https://kind.sigs.k8s.io/)
