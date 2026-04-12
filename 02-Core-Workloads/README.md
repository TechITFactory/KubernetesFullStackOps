# Part 2: CONCEPTS

## Intro

Part 2 turns what you installed in [Part 1](../01-Local-First-Operations/README.md) into a **clear model**: how the control plane and nodes cooperate, how workloads and networking are expressed, and where security and policy hooks sit. Before you dive in, you need a cluster whose API answers `kubectl` — otherwise the lessons stay abstract.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/02-Core-Workloads"
```

> If you set `COURSE_DIR` earlier this session, skip the export and just `cd`.

## Flow of this lesson

```
  2.1 Overview, API, kubectl
           │
           ▼
  2.2 Architecture
           │
           ▼
  2.4 Workloads ──▶ 2.5 Networking ──▶ 2.7 Configuration
           │              │                    │
           │              │                    ▼
           │              │             2.6 Storage
           │              │                    │
           │              └────────┬───────────┘
           │                       ▼
           │                2.10 Scheduling
           │                       │
           │                       ▼
           │                 2.8 Security
           │                       │
           │                       ▼
           │                  2.9 Policies
           │                       │
           │                       ▼
           └──────────────▶ 2.11 Cluster admin
```

**Say:**

We start with the overview, API, and kubectl so every later lesson has shared vocabulary. Architecture comes next, then workloads and networking. Configuration and storage sit beside scheduling; security and policies wrap the operational core; cluster administration ties it together. Optional Windows and extensions modules follow if your role needs them.

**Prerequisites met?** From this folder, run:

```bash
bash scripts/verify-part2-prerequisites.sh
```

You should see `cluster-info`, a successful `/readyz` check, and your nodes listed. If this fails, fix context and connectivity in [Part 1](../01-Local-First-Operations/README.md) before continuing.

---

## Step 1 — Confirm repo location and prerequisites script

**What happens when you run this:**

`cd` moves into `02-Core-Workloads`. The `bash` command runs the prerequisite checker against your current kubeconfig — read-only checks plus API probes as implemented in the script.

**Say:**

I make sure I am in the course’s Part 2 directory so script paths work, then I run the gate script the same way every time I start Part 2.

**Run:**

```bash
cd "$COURSE_DIR/02-Core-Workloads"
bash scripts/verify-part2-prerequisites.sh
```

**Expected:**

Script exits successfully; output mentions cluster reachability (wording depends on script version).

---

## Step 2 — Skim the module list (no cluster changes)

**What happens when you run this:**

You open the links below in the editor or browser — no commands required. This orients you to what exists in the repo.

**Say:**

I scan the module list once so I know where workloads, networking, and security live before I follow the suggested order.

**Run:**

_(No command — open the **Modules** list in this file.)_

**Expected:**

You know which path you will take after **2.1** (suggested: **2.1 → 2.2 → 2.4 → 2.5 → 2.7 → 2.6 → 2.10 → 2.8 → 2.9 → 2.11**, then optional **2.12** and **2.13**).

---

## Troubleshooting

- **`The connection to the server localhost:8080 was refused`** (or similar) from `kubectl` → wrong kubeconfig or cluster down; run `kubectl config current-context` and restart Minikube, Kind, or your lab control plane
- **`verify-part2-prerequisites.sh: command not found`** → run from `$COURSE_DIR/02-Core-Workloads` or pass the full path to the script
- **`error: You must be logged in to the server`** → refresh cloud or OIDC credentials per your provider’s docs
- **`Unable to connect to the server: x509: certificate signed by unknown authority`** → kubeconfig cluster CA data stale; re-fetch admin kubeconfig from the cluster bootstrap path you use

---

## Learning objective

- Located `02-Core-Workloads` in the repo and ran the Part 2 prerequisite script successfully.
- Mapped the suggested concept order from overview through cluster administration.
- Chose whether optional Windows and extension modules apply to your role.

## Why this matters

Concepts land faster when each lesson can hit a real API. Running the gate script once saves hours of confusion from stale contexts or dead endpoints.

## Video close — fast validation

**What happens when you run this:**

These `kubectl` calls are read-only: they confirm API reachability, list a slice of resource types, list namespaces, and show nodes if RBAC allows.

**Say:**

This is my ten-second orientation: cluster info, a sample of API resources, namespaces, nodes.

**Run:**

```bash
kubectl cluster-info
kubectl api-resources | head -n 30
kubectl get ns
kubectl get nodes -o wide 2>/dev/null || true
```

**Expected:**

A control plane URL; a non-empty api-resources table; namespace list; node list or a harmless empty result on restricted clusters.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/verify-part2-prerequisites.sh` | Part 2 gate — cluster reachability checks |
| `01-overview/README.md` | Entry module for API and kubectl mental model |

---

## Modules

- [01 Overview](01-overview/README.md)
- [02 Cluster Architecture](02-cluster-architecture/README.md)
- [03 Containers](03-containers/README.md)
- [04 Workloads](04-workloads/README.md)
- [05 Services, Load Balancing, and Networking](05-services-load-balancing-and-networking/README.md)
- [06 Storage](06-storage/README.md)
- [07 Configuration](07-configuration/README.md)
- [08 Security](08-security/README.md)
- [09 Policies](09-policies/README.md)
- [10 Scheduling, Preemption and Eviction](10-scheduling-preemption-and-eviction/README.md)
- [11 Cluster Administration](11-cluster-administration/README.md)
- [12 Windows in Kubernetes](12-windows-in-kubernetes/README.md)
- [13 Extending Kubernetes](13-extending-kubernetes/README.md)

**Format note:** Lessons in **01**, **02**, and **03** use a **teaching transcript** style: **What happens when you run this** before runnable blocks, **Expected** outputs, **Video close** recap commands, and `scripts/*.sh` files include a **WHAT THIS DOES WHEN YOU RUN IT** header where scripts exist. **04 Workloads** — module README, pods, workload-api parents, and individual lessons match that pattern; other sub-lessons may still use shorter stubs until expanded. **05 Networking** — module README plus the Service lesson; other networking lessons vary in depth until expanded.

---

## Next

Open [01 Overview](01-overview/README.md) and work the children in order.
