# Break & Fix Labs

10 hands-on labs that simulate real CKA exam scenarios. Each lab breaks something in your kind cluster — you diagnose and fix it.

## Prerequisites

```bash
brew install kind kubectl docker
```

## Setup

```bash
# Create the practice cluster (1 control-plane + 2 workers)
./scripts/create-cluster.sh

# Verify it's working
kubectl get nodes
```

## How to use

```bash
# 1. Break something
./scripts/break.sh lab-01-node-not-ready

# 2. Read the scenario, diagnose, fix
# (use kubectl, docker exec to SSH into nodes)

# 3. Verify your fix
./scripts/verify.sh lab-01-node-not-ready

# 4. Reset if needed
./scripts/reset.sh
```

## Labs by CKA Domain

### Troubleshooting (30% of exam)
| Lab | Scenario | Difficulty |
|-----|----------|------------|
| lab-01 | Node NotReady — kubelet stopped | Easy |
| lab-02 | Service has no endpoints — selector mismatch | Easy |
| lab-03 | Pod CrashLoopBackOff — missing config file | Medium |
| lab-10 | Kubelet misconfigured — wrong config path | Hard |

### Cluster Architecture (25% of exam)
| Lab | Scenario | Difficulty |
|-----|----------|------------|
| lab-04 | Scheduler down — static pod removed | Medium |
| lab-05 | Certificate inspection & renewal | Medium |
| lab-09 | etcd backup & restore | Hard |

### Services & Networking (20% of exam)
| Lab | Scenario | Difficulty |
|-----|----------|------------|
| lab-06 | NetworkPolicy blocks traffic — fix the rule | Hard |

### Storage (10% of exam)
| Lab | Scenario | Difficulty |
|-----|----------|------------|
| lab-07 | PVC stuck Pending — capacity mismatch | Easy |

### Security / RBAC
| Lab | Scenario | Difficulty |
|-----|----------|------------|
| lab-08 | ServiceAccount missing permissions | Medium |

## SSH into nodes

kind nodes are Docker containers. "SSH" into them with:

```bash
# Control plane
docker exec -it cka-lab-control-plane bash

# Worker 1
docker exec -it cka-lab-worker bash

# Worker 2
docker exec -it cka-lab-worker2 bash
```

## Tips

- Always start with `kubectl get nodes` and `kubectl get pods -A` to see the big picture
- Check events: `kubectl get events -A --sort-by=.metadata.creationTimestamp`
- For node issues: `systemctl status kubelet` and `journalctl -u kubelet` inside the node
- Time yourself — CKA gives ~6 minutes per question on average
