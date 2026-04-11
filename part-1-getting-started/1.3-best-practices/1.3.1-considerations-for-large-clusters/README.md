# 1.3.1 Considerations for Large Clusters — teaching transcript

- **Summary**: Large clusters demand deliberate design around scalability, failure domains, API efficiency, and workload distribution.
- **Content**: Node and pod sizing guardrails, topology spread, API budget awareness, and operational readiness checks before cluster growth.
- **Lab**: Review the planning checklist, apply the topology spread example, and validate a scale-readiness baseline.

## Assets

- `scripts/check-large-cluster-readiness.sh`
- `yamls/large-cluster-planning-checklist.yaml`
- `yamls/topology-spread-sample.yaml`
- `yamls/failure-troubleshooting.yaml`

**Teaching tip:** **What happens when you run this** is below each Run block. Script behavior is documented in the header of `scripts/check-large-cluster-readiness.sh`.

---

## Intro

Alright — in this lesson we're talking about what breaks when a cluster grows.

Most Kubernetes problems at scale don't come from a sudden spike. They come from **skipped planning**: you added nodes until something fell over, then figured out why.

The goal here is to give you a **pre-scale gate** — a set of checks you run *before* you grow, not after.

Kubernetes has documented hard limits:
- **5,000 nodes** per cluster
- **110 pods per node** (default)
- **300,000 total pods**
- **150,000 total Services**

Most teams won't hit those. But the **soft limits** — etcd write latency, API server queue depth, controller loop time — start showing up at 50–100 nodes if you haven't thought about them.

The three failure patterns I see most at scale:

1. **Pods pile up on one node** — because scheduling is unconstrained.
2. **The API server slows down** — because everything is polling instead of watching.
3. **etcd gets hot** — because secrets and ConfigMaps are created and deleted at high frequency.

This lesson gives you tools to spot all three before they hurt.

---

## Flow of this lesson

**Say:**
Two stages: run the readiness check to see where you stand, then apply the topology spread sample to see how scheduling constraints look in practice.

```
  [ Step 1 ]              [ Step 2 ]              [ Step 3 ]
  Run readiness    →      Apply topology    →      Verify pod
  check script            spread sample            placement
```

---

## Step 1 — Run the scale readiness check

**What happens when you run this:**
`check-large-cluster-readiness.sh` queries the cluster API (read-only): counts nodes and pods, checks for PriorityClass and PodDisruptionBudget objects, probes `/readyz` on the API server, and prints zone topology labels per node. It exits with warnings for anything that could become a scaling problem.

**Say:**
This script is a read-only audit. It doesn't change anything. Think of it as a pre-flight checklist — I want to see where we stand *before* I add more nodes or workloads.

**Run:**

```bash
./scripts/check-large-cluster-readiness.sh
```

**Expected:**
Output with pass/warn lines per check. Warnings are not failures — they're items to review. A cluster with no PriorityClasses, no PodDisruptionBudgets, and no zone labels is not necessarily broken, but it is not ready to scale safely.

---

## Step 2 — Apply the topology spread sample

**What happens when you run this:**
`kubectl apply -f yamls/topology-spread-sample.yaml` creates a Deployment with `topologySpreadConstraints` — the scheduler tries to spread pods evenly across nodes (or zones, depending on your label setup). Declarative; safe to re-apply.

**Say:**
Without spread constraints, the scheduler fills one node before moving to another — that's fine for small clusters, but at scale it creates hot nodes.

`topologySpreadConstraints` tells the scheduler: keep the difference in pod count between any two nodes below a `maxSkew`. Let me show what that looks like deployed.

**Run:**

```bash
kubectl apply -f yamls/topology-spread-sample.yaml
```

**Expected:**
Resources created or unchanged. No errors.

---

## Step 3 — Verify pod placement across nodes

**What happens when you run this:**
`kubectl get pods -o wide` lists pods with the node each one landed on. This is a read-only view.

**Say:**
The `-o wide` flag is the quickest way to see scheduling decisions. I want to confirm the pods from the topology spread sample are distributed across nodes — not all stacked on one.

**Run:**

```bash
kubectl get pods -o wide
```

**Expected:**
Pods from the spread sample distributed across nodes. On a single-node cluster (Minikube/Kind with one node) they will all land on the same node — that is expected; constraints are respected when the topology exists.

---

## Why topology spread matters at scale

A single node carrying 80% of your pods is a single point of failure — not because Kubernetes can't reschedule them, but because rescheduling 2,000 pods simultaneously hammers the API server and triggers image pulls on every other node at the same time.

With spread constraints in place:
- Node failure affects a proportional slice of pods, not all of them.
- Image pull load is distributed on rollout.
- The scheduler keeps your cluster balanced automatically.

The other tool for this is **PodDisruptionBudgets** — they let you control how many pods can be voluntarily removed during node drains. Without PDBs, a rolling node upgrade can take down more replicas than you intended.

**Real pattern:** production platform teams usually combine three things:
1. `topologySpreadConstraints` on the Deployment
2. A `PodDisruptionBudget` capping voluntary disruption to one pod at a time
3. Node groups in multiple availability zones (covered in 1.3.2)

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/check-large-cluster-readiness.sh` | Read-only pre-scale audit |
| `yamls/large-cluster-planning-checklist.yaml` | ConfigMap checklist for tracking decisions |
| `yamls/topology-spread-sample.yaml` | Deployment with spread constraints |
| `yamls/failure-troubleshooting.yaml` | Common scale and scheduling failures |

---

## Troubleshooting

- **check script exits non-zero** → read each FAIL line; most are warnings, not hard blockers. Fix the ones relevant to your cluster size.
- **Pods all land on one node** → confirm `topologyKey` in the spread constraint matches your node labels (`kubectl get nodes --show-labels`)
- **No zone labels on nodes** → covered in 1.3.2; spread by zone requires zone labels to exist first
- **API server slow or timing out** → check `kubectl get --raw /readyz`; check `kube-apiserver` pod resource usage

---

## Learning objective

- Run the pre-scale readiness check and interpret its output.
- Apply topology spread constraints and verify pod distribution.
- Name the three most common scaling failure patterns and the Kubernetes objects that prevent them.

## Why this matters

The teams that hit unexpected scaling problems are almost always the ones who didn't set a pre-scale gate. Adding these checks before a growth event — not after — is the difference between a planned capacity increase and an unplanned incident.

---

## Video close — fast validation

**What happens when you run this:**
Re-run readiness script; wide node and pod lists — read-only recap of current state.

**Say:**
I always run these three commands after a change that touches scheduling or capacity. Nodes wide, pods wide, readiness check. That's my baseline snapshot.

```bash
./scripts/check-large-cluster-readiness.sh
kubectl get nodes -o wide
kubectl get pods -o wide
```

---

## Next

[1.3.2 Running in multiple zones](../1.3.2-running-in-multiple-zones/README.md)
