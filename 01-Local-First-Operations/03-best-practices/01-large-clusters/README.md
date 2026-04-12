# 01 Considerations for Large Clusters — teaching transcript

## Intro

Alright — in this lesson we're talking about what breaks when a cluster grows.

Most Kubernetes problems at scale don't come from a sudden spike. They come from **skipped planning**: you added nodes until something fell over, then figured out why.

The goal here is a **pre-scale gate** — checks you run *before* you grow, not after.

Kubernetes documents hard limits such as **about 5,000 nodes**, **about 110 pods per node** (default), and on the order of **300,000 pods** cluster-wide. You may never hit those numbers, but long before them you see **soft failures**: one node hoarding pods, the API server drowning in chatter, or the scheduler taking noticeably longer to place workloads.

The three failure patterns I see most:

1. **Noisy neighbor on a node** — scheduling is unconstrained, so one node becomes a hot spot.
2. **API saturation** — too many clients poll or list huge objects instead of watching efficiently.
3. **Scheduling latency** — the queue backs up because requests, limits, and spread rules fight each other.

We will run the course readiness script, apply a `topologySpreadConstraints` sample with **`maxSkew`**, and verify placement. I will also name **PodDisruptionBudgets** as the companion object that caps voluntary disruption during drains.

**Teaching tip:** **WHAT THIS DOES WHEN YOU RUN IT** is in `scripts/check-large-cluster-readiness.sh`.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/03-best-practices/01-large-clusters"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  [ Step 1 ]              [ Step 2 ]              [ Step 3 ]
  cd + chmod        →     Run readiness     →     Apply topology
  (optional)               check script            spread sample
                                    │
                                    ▼
                            [ Step 4 ]
                            Verify pod
                            placement (-o wide)
```

**Say:**

We land in the lesson folder, run the read-only readiness script, apply the spread sample, then read pod placement with `kubectl get pods -o wide` so we see how skew limits express themselves on real nodes.

---

## Step 1 — Open this lesson in the terminal

**What happens when you run this:**

`cd` moves into the lesson directory. `chmod +x scripts/*.sh` marks scripts executable if your checkout cleared the execute bit — metadata only.

**Say:**

I work here so `./scripts` and `./yamls` paths match the repo layout on disk.

**Run:**

```bash
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/03-best-practices/01-large-clusters"
chmod +x scripts/*.sh 2>/dev/null || true
pwd
```

**Expected:**

Path ending with `03.1-considerations-for-large-clusters`.

---

## Step 2 — Run the scale readiness check

**What happens when you run this:**

`check-large-cluster-readiness.sh` queries the API (read-only): node and pod counts, checks for **PriorityClass** and **PodDisruptionBudget** objects, probes `/readyz`, and prints topology labels — per the script’s own header. It exits non-zero when the script authors decided a hard FAIL is warranted; otherwise expect PASS/WARN lines.

**Say:**

This script does not mutate the cluster. It is a pre-flight sheet — I want signals about PDBs, priorities, and topology **before** I add another node pool.

**Run:**

```bash
./scripts/check-large-cluster-readiness.sh
```

**Expected:**

PASS/WARN/FAIL style lines. Warnings are review items, not always blockers.

---

## Step 3 — Apply the topology spread sample

**What happens when you run this:**

`kubectl apply -f yamls/topology-spread-sample.yaml` creates a Deployment whose `topologySpreadConstraints` cap imbalance across topology domains using **`maxSkew`** — declarative, idempotent.

**Say:**

`maxSkew` bounds how many more pods may sit on any domain than the least-loaded domain. Pair this style of guardrail with **PodDisruptionBudgets** so node drains cannot evict more replicas than you can afford at once.

**Run:**

```bash
kubectl apply -f yamls/topology-spread-sample.yaml
```

**Expected:**

Resources created or unchanged.

---

## Step 4 — Verify pod placement across nodes

**What happens when you run this:**

`kubectl get pods -o wide` lists pods with node names — read-only.

**Say:**

On a single-node Minikube or single-worker Kind cluster every pod may land together; that is expected when the topology has only one domain. On multi-node clusters you should see the spread attempt to respect skew.

**Run:**

```bash
kubectl get pods -o wide
```

**Expected:**

Pods from the sample Deployment listed with `NODE` values; distribution depends on cluster shape.

---

## Troubleshooting

- **`check-large-cluster-readiness.sh: Permission denied`** → `chmod +x scripts/*.sh`
- **`Unable to connect to the server`** → fix kubeconfig context; `kubectl cluster-info`
- **`pods share one node on Kind/Minikube`** → single schedulable node is normal; add workers or read labels to confirm topology keys exist
- **`0/3 pods scheduled` with `DoNotSchedule` spread** → fewer topology domains than replicas; relax `whenUnsatisfiable` or shrink replicas for the lab
- **`kubectl apply` fails with `Forbidden`** → your RBAC may block creates; run on a lab cluster with developer admin

---

## Learning objective

- Ran the pre-scale readiness script and interpreted PASS versus WARN lines.
- Applied a Deployment that uses `topologySpreadConstraints` including **`maxSkew`**, and inspected placement with `-o wide`.
- Named Kubernetes scale guardrails (hard limits, noisy-neighbor placement, API load, scheduler latency) and cited **PodDisruptionBudgets** for drain safety.

## Why this matters

Teams that grow clusters without spread rules and disruption budgets learn about them during the first maintenance window or node failure. Running a gate **before** capacity changes turns those surprises into planned work.

## Video close — fast validation

**What happens when you run this:**

Read-only recap: readiness script (may WARN), nodes wide, pods wide.

**Say:**

I re-run the script for the camera, then show nodes and pods wide — no applies in the closing beat.

**Run:**

```bash
./scripts/check-large-cluster-readiness.sh || true
kubectl get nodes -o wide
kubectl get pods -o wide
```

**Expected:**

Script output; node list; pod list with nodes. `|| true` keeps the block from failing the lesson if the script exits non-zero on a tiny cluster.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/check-large-cluster-readiness.sh` | Read-only pre-scale audit |
| `yamls/large-cluster-planning-checklist.yaml` | ConfigMap checklist for tracking decisions |
| `yamls/topology-spread-sample.yaml` | Deployment with spread constraints |
| `yamls/failure-troubleshooting.yaml` | Common scale and scheduling failures |

---

## Next

[02 Running in multiple zones](../02-running-in-multiple-zones/README.md)
