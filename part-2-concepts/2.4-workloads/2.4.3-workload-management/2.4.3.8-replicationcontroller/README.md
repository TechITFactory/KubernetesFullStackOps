# 2.4.3.8 ReplicationController — teaching transcript

## Intro

**ReplicationController** is the original **v1** API for “keep N pods with this label.” **ReplicaSet** (`apps/v1`) succeeded it with **set-based selectors** and tighter integration with **Deployment**. ReplicationController **lacks** first-class **rolling update** support—clients had to orchestrate replacements manually. **Always use Deployment (→ ReplicaSet)** for new work. This lesson is **historical**: recognize **`kind: ReplicationController`** in old clusters, tutorials, or vendor samples, then **migrate** to Deployment with equivalent labels and a proper **rollingUpdate** strategy.

**Prerequisites:** [2.4.3.2 ReplicaSet](../2.4.3.2-replicaset/README.md); [2.4.3.7 CronJob](../2.4.3.7-cronjob/README.md).

## Learning objective

- Describe ReplicationController as the **legacy** predecessor to ReplicaSet.
- Explain **equality-based** selector limits and **lack of rolling updates** compared to Deployment.
- State the **migration** recommendation: **Deployment** for all new workloads.

## Why this matters

Seeing `rc` in production signals **technical debt**—plan migration before you need modern rollout features.

## Flow of this lesson

```
  ReplicationController (legacy v1)
              │
              ▼
  Pods (same idea as ReplicaSet, older API)
              │
              ▼
  Prefer: Deployment → ReplicaSet → Pods
```

**Say:**

Behavior feels like ReplicaSet; the **ecosystem** around RC is what aged out.

## Concepts (short theory)

- **`kubectl get rc`** still works where old objects exist.

---

## Step 1 — Apply ReplicationController

**What happens when you run this:**

**v1** ReplicationController runs two **nginx** pods with **`app=rc-demo`**—operationally similar to ReplicaSet lab.

**Say:**

I compare mentally to [2.4.3.2](../2.4.3.2-replicaset/README.md) without re-filming that lesson.

**Run:**

```bash
kubectl apply -f yamls/replicationcontroller-demo.yaml
kubectl get rc rc-demo
kubectl get pods -l app=rc-demo -o wide
```

**Expected:** `rc-demo` shows desired replicas; two pods **Running**.

---

## Step 2 — Verify script

**What happens when you run this:**

Checks replica and ready counts for the RC.

**Run:**

```bash
chmod +x scripts/verify-replicationcontroller-lesson.sh
./scripts/verify-replicationcontroller-lesson.sh
```

**Expected:** Script succeeds.

## Troubleshooting

- **Why not edit RC in prod?** → No Deployment-style rollout—use **Deployment** migration
- **Selector overlap with Deployment** → accidental double ownership—unique labels
- **`rc` not found** → API disabled or never created—lesson still valid historically
- **Migration cutover** → create **Deployment** with same template, scale RC down, then delete
- **Rolling update expectation** → RC will disappoint—set expectations with leadership
- **Verify fails** → stale pods from partial apply

## Video close — fast validation

```bash
kubectl describe rc rc-demo | sed -n '/Replicas:/,/Pod Status:/p'
kubectl get pods -l app=rc-demo -o wide
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/replicationcontroller-demo.yaml` | Two-replica nginx RC |
| `yamls/failure-troubleshooting.yaml` | Legacy pitfalls / migration |
| `scripts/verify-replicationcontroller-lesson.sh` | Replica / ready count check |

## Cleanup

```bash
kubectl delete -f yamls/replicationcontroller-demo.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.4 Managing Workloads](../../2.4.4-managing-workloads/README.md)
