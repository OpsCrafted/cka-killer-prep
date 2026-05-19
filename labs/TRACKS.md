# Lab Tracks - Guided Learning Paths

Curated scenario sequences by learning goal and experience level.

## Beginner: First CKA Repair Path (90 min)

**Scenarios:** s01, s02, s04, s14, s26, s28, s31, s33

Core troubleshooting. Learn API server, nodes, services, deployments.

1. s01 (15m) - API server down
2. s02 (15m) - Node NotReady
3. s04 (12m) - Service no endpoints
4. s14 (10m) - Label worker node
5. s26 (10m) - LoadBalancer expose
6. s28 (10m) - Service discovery
7. s31 (10m) - Deployment rolling update
8. s33 (10m) - Resource limits

**Next:** troubleshooting-mastery

---

## Intermediate Tracks

### Troubleshooting Mastery (180 min)

**Scenarios:** s01-s10, s12-s13

Master all failure modes: API server, nodes, DNS, networking, scheduling, RBAC, storage, kubelet, upgrades.

~15 min per scenario. Core exam competency.

**Next:** advanced-cluster-ops

### Networking Deep Dive (120 min)

**Scenarios:** s03, s04, s23-s30

DNS, services, Ingress, Gateway API, NetworkPolicy, LoadBalancer, multi-tenancy.

- s03, s04: Service/DNS foundation
- s23-s26: Ingress, Gateway, policies, LoadBalancer
- s27-s30: DNS debugging, service discovery, multi-tenant isolation

### Storage & Persistence (80 min)

**Scenarios:** s09, s22, s37-s40

PV/PVC, StorageClass, local storage, backups, expansion.

- s09: PVC stuck
- s22: Backup etcd
- s37-s40: PV/PVC binding, StorageClass, local storage, expansion

### Workloads & Scaling (90 min)

**Scenarios:** s05, s31-s36

Deployment lifecycle, StatefulSets, resources, affinity, priority, HPA.

- s05: Pod CrashLoopBackOff
- s31: Deployment rolling
- s32: StatefulSet
- s33: Resource limits
- s34: Affinity/taints
- s35: Priority/preemption
- s36: HPA autoscaling

---

## Advanced: Advanced Cluster Operations (150 min)

**Scenarios:** s11, s16-s21

etcd restore, CNI migration, custom APIs, webhooks, audit logging, RBAC design, cross-namespace access.

Control plane, security, extensibility. Requires troubleshooting-mastery prerequisite.

---

## Exam Simulation (90 min)

**Scenarios:** s02, s05, s10, s23, s31, s37, s08, s20

Timed exam-like experience. Mixed domains, realistic pressure.

~11 min per scenario.

---

## Usage

```bash
cd labs

# Run track scenarios manually
./run.sh 01   # First Repairs - s01
./run.sh 02   # First Repairs - s02
...

# Or check tracks.yaml for ordered lists
grep -A 3 "first-repairs:" tracks.yaml
```

---

## Time Budgets

| Track | Scenarios | Time |
|-------|-----------|------|
| First Repairs | 8 | 90m |
| Troubleshooting Mastery | 12 | 180m |
| Networking | 10 | 120m |
| Storage | 6 | 80m |
| Workloads | 7 | 90m |
| Advanced Ops | 7 | 150m |
| Exam Sim | 8 | 90m |

---

## CKA Prep Paths

**1 week:** First Repairs (1.5h) + Troubleshooting Mastery (3h) = 4.5h

**2 weeks:** Above + one specialty track = 6-7h

**3 weeks:** Both foundations + all specialties + exam sim = 11-12h
