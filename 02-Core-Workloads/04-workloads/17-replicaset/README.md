# 2.4.3.2 ReplicaSet — teaching transcript

## Intro

A **ReplicaSet** ensures a number of Pods exist whose **labels match** its **selector**. It creates or deletes Pods to reconcile **current** vs **desired** count. **Deployments** manage ReplicaSets for you and implement **rolling updates** and **history**; a **standalone** ReplicaSet has **no rollout strategy**—changing the template is awkward (often delete/recreate the RS or run a one-off migration). The **selector is immutable** after creation in normal workflows; if Pod labels drift from the selector, you get **orphans** or **duplicate controllers** fighting the same labels. **Never edit a Deployment-owned ReplicaSet’s template directly**—the Deployment controller reconciles it back or you create inconsistent state.

**Prerequisites:** [2.4.3.1 Deployments](../2.4.3.1-deployments/README.md).

## Learning objective

- Create a **ReplicaSet** directly and see it **own** Pods via labels.
- Contrast standalone ReplicaSet with **Deployment-owned** ReplicaSets.
- Explain **selector immutability** and orphan risks.

## Why this matters

Incidents surface ReplicaSet objects: orphaned RS after bad rollouts, selector clashes, or manual pod delete churn. Knowing the controller’s job separates platform from app issues.

## Flow of this lesson

```
  ReplicaSet (selector + replicas + template)
              │
              ▼
  Pods with matching labels only
```

**Say:**

ReplicaSet is the **engine**; Deployment is the **product** most developers should drive.

## Concepts (short theory)

- Template updates on a standalone RS do not “roll” like a Deployment—you must understand pod recreation behavior.

---

## Step 1 — Apply ReplicaSet and inspect

**What happens when you run this:**

ReplicaSet **`replicaset-demo`** creates two nginx Pods labeled **`app=replicaset-demo`**. No Deployment object is in this manifest.

**Say:**

I emphasize **DESIRED/CURRENT/READY** columns on **`kubectl get rs`** as the health summary.

**Run:**

```bash
kubectl apply -f yamls/replicaset-demo.yaml
kubectl get rs replicaset-demo
kubectl get pods -l app=replicaset-demo -o wide
kubectl describe rs replicaset-demo | sed -n '/Replicas:/,/Events:/p'
```

**Expected:** `DESIRED` = `CURRENT` = `READY` = 2; two pods on nodes (placement varies).

---

## Step 2 — Verify script

**What happens when you run this:**

Automated check for replica and ready counts.

**Say:**

If **deployment-demo** still exists from the prior lesson, both can coexist—different label values.

**Run:**

```bash
chmod +x scripts/verify-replicaset-lesson.sh
./scripts/verify-replicaset-lesson.sh
```

**Expected:** Script succeeds.

## Troubleshooting

- **`ReplicaFailure` or low READY** → describe RS; follow to **Events** and failing Pods
- **Too many pods** → overlapping selectors with another workload—label collision
- **Changing selector fails** → immutability; recreate RS and migrate pods carefully
- **Edited RS under Deployment** → Deployment immediately reconciles—use **`kubectl set`** / edit **Deployment**
- **Pod `Pending`** → cluster capacity—not ReplicaSet-specific
- **Verify fails** → wrong labels or partial delete

## Video close — fast validation

**Say:**

Slice stops at **Pod Status** so you do not drown in event noise.

```bash
kubectl describe rs replicaset-demo | sed -n '/Replicas:/,/Pod Status:/p'
kubectl get pods -l app=replicaset-demo -o wide
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/replicaset-demo.yaml` | Two-replica nginx ReplicaSet |
| `yamls/failure-troubleshooting.yaml` | Selector and orphan scenarios |
| `scripts/verify-replicaset-lesson.sh` | Checks replica and ready counts |

## Cleanup

```bash
kubectl delete -f yamls/replicaset-demo.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.3.3 StatefulSets](../2.4.3.3-statefulsets/README.md)
