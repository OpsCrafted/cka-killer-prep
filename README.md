# 🎯 CKA Killer Prep

**Interactive Certified Kubernetes Administrator exam preparation — study guide, 25-question KillerShell simulator, JSONPath drills, and 40 scenarios (37 hands-on labs, 3 design labs).**

[![GitHub Pages](https://img.shields.io/badge/Live_Site-GitHub_Pages-blue?style=flat-square&logo=github)](https://OpsCrafted.github.io/cka-killer-prep)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![CKA Exam](https://img.shields.io/badge/CKA-v1.31-purple?style=flat-square&logo=kubernetes)](https://training.linuxfoundation.org/certification/certified-kubernetes-administrator-cka/)

---

## What is this?

A hands-on CKA prep platform built by a Senior SRE running Kubernetes in production. Not another wall of markdown — this is an interactive course with progress tracking, break-and-fix labs, and the full KillerShell simulator question bank with weighted scoring.

### What's inside

| Module               | Description                                                                    | Format           |
| -------------------- | ------------------------------------------------------------------------------ | ---------------- |
| **Study Guide**      | 6 chapters covering all CKA domains — lessons, exercises, quizzes, cheatsheets | Interactive HTML |
| **KillerShell 25Q**  | 25 simulator questions with exam weights, solutions, and tips                  | Interactive HTML |
| **JSONPath Drills**  | 20 type-to-check drills for kubectl filtering — the skill most people skip     | Interactive HTML |
| **Break & Fix Labs** | Shell scripts that break a kind cluster — you diagnose and fix                 | Shell + kind     |
| **Quick Reference**  | Node scheduling, RBAC, NetworkPolicy, etcd backup — visual explainers          | Interactive HTML |

### Who is this for?

- Engineers with Kubernetes experience preparing for the CKA exam
- SREs who want structured hands-on practice, not just theory
- Anyone who's failed CKA once and needs targeted practice on weak areas

---

## 🚀 Quick Start

### Option 1: Use the hosted site (no setup)

👉 **[Open the live site](https://opscrafted.github.io/cka-killer-prep/)**

Everything runs in the browser. Progress is saved locally.

### Option 2: Run locally

```bash
git clone https://github.com/opscrafted/cka-killer-prep.git
cd cka-killer-prep

# Open the main page
open index.html
# or
python3 -m http.server 8080  # then visit localhost:8080
```

### Option 3: Run the break-and-fix labs (requires kind + Docker)

```bash
# Prerequisites
brew install kind kubectl

# Run a specific lab scenario (auto-creates cluster)
cd labs
./run.sh 01

# Fix it, then verify
./run.sh verify 01

# Reset and retry
./run.sh reset 01
```

---

## 📁 Repo Structure

```
cka-killer-prep/
├── index.html                  # Landing page (GitHub Pages entry point)
├── study-guide.html            # 6-chapter interactive study guide
├── killershell-25q.html        # KillerShell simulator (25 questions, exam weighted)
├── jsonpath-drills.html        # JSONPath & kubectl filtering (20 drills)
├── labs/
│   ├── README.md               # Lab setup & commands
│   ├── run.sh                  # Lab runner: setup, verify, reset one scenario
│   ├── test-all.sh             # Run all 40 scenarios, generates reports (JSON + Markdown)
│   ├── random-exam.sh          # Exam simulator: 8 random scenarios, 70%+ pass/fail
│   ├── generate-readme-tables.sh  # Generate scenario matrix from metadata
│   ├── kind-config.yaml        # kind cluster config
│   ├── scenarios/
│   │   ├── s01-s20/            # Ready (20 scenarios): API troubleshooting, debugging
│   │   ├── s21-s40/            # Ready (17 scenarios) + Design (3 scenarios): workloads, storage, RBAC
│   │   └── each scenario has: TASK.md, SOLUTION.md, HINTS.md, setup.sh, verify.sh, reset.sh, meta.yaml
│   └── .state/                 # Runtime: kubeconfig, reports (JSON + Markdown)
├── LICENSE
└── README.md
```

---

## 📊 CKA Exam Domains & Weights

| Domain                                             | Weight | Covered in                                            |
| -------------------------------------------------- | ------ | ----------------------------------------------------- |
| Cluster Architecture, Installation & Configuration | 25%    | Study Guide Ch1-2, Labs s13-s20, KillerShell Q2-4    |
| Workloads & Scheduling                             | 15%    | Study Guide Ch3, Labs s31-s36, KillerShell Q9,11-13  |
| Services & Networking                              | 20%    | Study Guide Ch4, Labs s23-s30, KillerShell Q24       |
| Storage                                            | 10%    | Study Guide Ch5, Labs s37-s40, KillerShell Q6        |
| Troubleshooting                                    | 30%    | Study Guide Ch6, Labs s01-s12, KillerShell Q7,15,17  |

---

## 🧪 Break & Fix Labs

Each lab follows the same pattern:

1. **Read the scenario** — what's broken and what the expected state should be (TASK.md)
2. **Run the break script** — it introduces a realistic failure into your kind cluster
3. **Diagnose and fix** — use only kubectl and ssh (like the real exam)
4. **Run the verify script** — it checks if your fix is correct
5. **Read the solution** — compare your approach (SOLUTION.md)

```bash
cd labs

# Example: s02 — Node Not Ready
./run.sh 02          # setup breaks cluster

# Now diagnose:
kubectl get nodes          # one node is NotReady
docker exec -it cka-lab-worker bash  # SSH into node to debug

# When you think it's fixed:
./run.sh verify 02
# ✅ PASS: Cluster healthy

# Compare with solution
cat scenarios/s02-node-not-ready/SOLUTION.md
```

---

## 📊 Scenario Status

**37 Ready (Hands-On Labs):** Fully executable break/fix scenarios
- Each lab breaks a Kubernetes cluster, you diagnose & fix it
- Verify script checks if your fix is correct
- Solutions provided for comparison

**3 Design Labs:** Conceptual guides (not executable)
- s24: Gateway API architecture & controller binding
- s29: GatewayClass controller reconciliation  
- s30: Multi-tenancy isolation layers
- Include DESIGN.md with architecture, debugging flow, and key concepts

---

## 🔧 Practice Environment Setup

### System Requirements

- **Docker or Podman** (for kind cluster)
- **kind** (Kubernetes in Docker)
- **kubectl**
- **jq** (for reporting)
- **macOS:** Bash 3.2+ (builtin), or newer via `brew install bash`
- **Linux:** Bash 4.0+
- **RAM:** 16GB+ (8GB minimum for single cluster)

### Dependencies

```bash
# macOS
brew install docker kind kubectl jq

# Linux (Ubuntu/Debian)
sudo apt-get install docker.io kind kubectl jq

# Windows (via Chocolatey)
choco install docker-desktop kind kubernetes-cli jq

# Windows (via winget)
winget install Docker.DockerDesktop
winget install kubernetes-cli
winget install jqlang.jq
# kind: download from https://kind.sigs.k8s.io/docs/user/quick-start/#installation

# Verify
kind --version
kubectl version --client
```

### Windows-Specific Setup

**Recommended: WSL2 (Windows Subsystem for Linux 2)**

```powershell
# PowerShell (Admin)
wsl --install -d Ubuntu-22.04

# Inside WSL2:
sudo apt-get update
sudo apt-get install docker.io kind kubectl jq

# Start Docker daemon
sudo dockerd &
```

**Alternative: Docker Desktop on Windows**

1. Install [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)
2. Enable WSL2 backend (Settings → Resources → WSL integration)
3. Install kubectl, kind, jq via Chocolatey (see above)
4. Use PowerShell or Git Bash terminal

---

## 🔧 Practice Environment Setup

### Using kind (recommended)

```bash
# Install
brew install kind kubectl

# Create a multi-node cluster for CKA practice
kind create cluster --name cka-lab --config labs/kind-config.yaml

# Verify
kubectl get nodes
# NAME                    STATUS   ROLES           AGE   VERSION
```

### Resource requirements

| Setup                             | RAM needed | Clusters               |
| --------------------------------- | ---------- | ---------------------- |
| 1 cluster (1 CP + 2 workers)      | ~2GB       | All labs               |
| 3 clusters (exam simulation)      | ~5GB       | Multi-context practice |
| 6 clusters (full KillerShell sim) | ~10GB      | Full exam simulation   |

---

## 🧪 Lab Scenario Matrix

All 40 scenarios implemented and tested. Generated from `labs/scenarios/*/meta.yaml` — status always current:

| Scenario | Topic | Domain | Status |
|----------|-------|--------|--------|
| **Troubleshooting** | | | |
| s01-api-server-down | api-server-down | Troubleshooting | ✓ |
| s02-node-not-ready | node-not-ready | Troubleshooting | ✓ |
| s03-coredns-broken | coredns-broken | Troubleshooting | ✓ |
| s04-service-no-endpoints | service-no-endpoints | Troubleshooting | ✓ |
| s05-pod-crashloop | pod-crashloop | Troubleshooting | ✓ |
| s06-scheduler-unresponsive | scheduler-unresponsive | Cluster Architecture | ✓ |
| s07-cert-expired | cert-expired | Cluster Architecture | ✓ |
| s08-netpol-blocking | netpol-blocking | Troubleshooting | ✓ |
| s09-pvc-stuck | pvc-stuck | Troubleshooting | ✓ |
| s10-rbac-forbidden | rbac-forbidden | Cluster Architecture | ✓ |
| s11-etcd-corruption | etcd-corruption | Cluster Architecture | ✓ |
| s12-kubelet-misconfigured | kubelet-misconfigured | Cluster Architecture | ✓ |
| **Cluster Architecture** | | | |
| s13-cluster-upgrade | cluster-upgrade | Cluster Architecture | ✓ |
| s14-node-join | node-join | Cluster Architecture | ✓ |
| s15-runtime-switch | runtime-switch | Cluster Architecture | ✓ |
| s16-cni-migration | cni-migration | Cluster Architecture | ✓ |
| s17-custom-api | custom-api | Cluster Architecture | ✓ |
| s18-webhook-config | webhook-config | Cluster Architecture | ✓ |
| s19-audit-logging | audit-logging | Cluster Architecture | ✓ |
| s20-rbac-design | rbac-design | Cluster Architecture | ✓ |
| **Services & Networking** | | | |
| s21-serviceaccount-binding | serviceaccount-binding | Cluster Architecture | ◐ |
| s22-backup-strategy | backup-strategy | Cluster Architecture | ◐ |
| s23-ingress-tls | ingress-tls | Services & Networking | ◐ |
| s24-gateway-api | gateway-api | Services & Networking | ◐ |
| s25-netpol-namespace | netpol-namespace | Services & Networking | ◐ |
| s26-loadbalancer-expose | loadbalancer-expose | Services & Networking | ◐ |
| s27-dns-debugging | dns-debugging | Services & Networking | ◐ |
| s28-service-discovery | service-discovery | Services & Networking | ◐ |
| s29-gatewayclass-binding | gatewayclass-binding | Services & Networking | ◐ |
| s30-multi-tenancy | multi-tenancy | Services & Networking | ◐ |
| **Workloads & Scheduling** | | | |
| s31-deployment-rolling | deployment-rolling | Workloads & Scheduling | ◐ |
| s32-statefulset-storage | statefulset-storage | Workloads & Scheduling | ◐ |
| s33-resource-limits | resource-limits | Workloads & Scheduling | ◐ |
| s34-affinity-taints | affinity-taints | Workloads & Scheduling | ◐ |
| s35-priority-preemption | priority-preemption | Workloads & Scheduling | ◐ |
| s36-hpa-scaling | hpa-scaling | Workloads & Scheduling | ◐ |
| **Storage** | | | |
| s37-pv-pvc-binding | pv-pvc-binding | Storage | ◐ |
| s38-storageclass-default | storageclass-default | Storage | ◐ |
| s39-local-storage | local-storage | Storage | ◐ |
| s40-pvc-expansion | pvc-expansion | Storage | ◐ |

Run all 40: `bash labs/test-all.sh`
Run single: `./labs/run.sh 01`
Verify: `./labs/run.sh verify 01`

---

## 📝 Exam Day Checklist

```bash
# Set up your aliases FIRST (this is allowed in the exam)
alias k=kubectl
export do="--dry-run=client -o yaml"
export now="--force --grace-period 0"

# Verify kubectl works
k get nodes

# Bookmark these in the exam browser:
# - https://kubernetes.io/docs
# - https://kubernetes.io/blog
```

---

## Contributing

Found an error? Want to add a lab? PRs welcome.

1. Fork the repo
2. Create a branch (`git checkout -b fix/lab-03-typo`)
3. Commit your changes
4. Push and open a PR

---

## Support

If this course helped you pass the CKA exam, consider buying me a coffee:

[![Buy Me a Coffee](https://img.shields.io/badge/Buy_Me_A_Coffee-FFDD00?style=flat-square&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/opscrafted)

---

## License

MIT — use it, share it, learn from it.

---

## Acknowledgments

- [KillerShell](https://killer.sh) for the original simulator questions
- [freeCodeCamp CKA Course 2026](https://www.youtube.com/watch?v=l57xKN6OBhY) for study guide structure
- [Kubernetes Official Docs](https://kubernetes.io/docs) — the only reference allowed in the exam

---

**Built by Borislav Stancevic — Senior SRE running Kubernetes in production.**
