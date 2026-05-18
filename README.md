# 🎯 CKA Killer Prep

**Interactive Certified Kubernetes Administrator exam preparation — study guide, 25-question KillerShell simulator, JSONPath drills, and 12 implemented break-and-fix labs (28 planned).**

[![GitHub Pages](https://img.shields.io/badge/Live_Site-GitHub_Pages-blue?style=flat-square&logo=github)](https://yourusername.github.io/cka-killer-prep)
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
brew install kind kubectl kubectx

# Create a practice cluster
./labs/scripts/create-cluster.sh

# Run a specific lab scenario
./labs/scripts/break.sh lab-01-node-not-ready

# Fix it, then verify
./labs/scripts/verify.sh lab-01-node-not-ready
```

---

## 📁 Repo Structure

```
cka-killer-prep/
├── index.html                  # Landing page (GitHub Pages entry point)
├── study-guide.html            # 6-chapter interactive study guide
├── killershell-25q.html        # KillerShell simulator question bank
├── jsonpath-drills.html        # JSONPath & bash filtering practice
├── labs/
│   ├── README.md               # Lab setup instructions
│   ├── scenarios/
│   │   ├── s01-api-server-down/          # ✓ implemented
│   │   ├── s02-node-not-ready/           # ✓ implemented
│   │   ├── s03-coredns-broken/           # ✓ implemented
│   │   ├── ... (s04-s12 implemented)
│   │   ├── s13-cluster-upgrade/          # 📋 planned
│   │   ├── s14-node-join/                # 📋 planned
│   │   ├── ... (s15-s40 planned)
│   └── run.sh                  # Lab runner (setup, verify, reset)
├── LICENSE
└── README.md
```

---

## 📊 CKA Exam Domains & Weights

| Domain                                             | Weight | Covered in                                            |
| -------------------------------------------------- | ------ | ----------------------------------------------------- |
| Cluster Architecture, Installation & Configuration | 25%    | Study Guide Ch1-2, Labs 4,5,9,13                      |
| Workloads & Scheduling                             | 15%    | Study Guide Ch3, KillerShell Q2-4,9,11-13             |
| Services & Networking                              | 20%    | Study Guide Ch4, Labs 6, KillerShell Q24              |
| Storage                                            | 10%    | Study Guide Ch5, KillerShell Q6, Lab 7,40             |
| Troubleshooting                                    | 30%    | Study Guide Ch6, Labs 1-3,10, KillerShell Q7,15,17,18 |

---

## 🧪 Break & Fix Labs

Each lab follows the same pattern:

1. **Read the scenario** — what's broken and what the expected state should be
2. **Run the break script** — it introduces a realistic failure into your kind cluster
3. **Diagnose and fix** — use only kubectl and ssh (like the real exam)
4. **Run the verify script** — it checks if your fix is correct
5. **Read the solution** — compare your approach

```bash
# Example: Lab 01 — Node Not Ready
./labs/scripts/break.sh lab-01-node-not-ready

# Now diagnose:
kubectl get nodes          # one node is NotReady
# SSH into the node, find the issue, fix it

# When you think it's fixed:
./labs/scripts/verify.sh lab-01-node-not-ready
# ✅ PASS: All nodes are Ready
```

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

## License

MIT — use it, share it, learn from it.

---

## Acknowledgments

- [KillerShell](https://killer.sh) for the original simulator questions
- [freeCodeCamp CKA Course 2026](https://www.youtube.com/watch?v=l57xKN6OBhY) for study guide structure
- [Kubernetes Official Docs](https://kubernetes.io/docs) — the only reference allowed in the exam

---

**Built by Borislav Stancevic — Senior SRE running Kubernetes in production.**
