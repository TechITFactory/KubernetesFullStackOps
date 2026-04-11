# 2.4.3.2 ReplicaSet â€” teaching transcript

## Intro

A **ReplicaSet** ensures a number of Pods exist whose **labels match** its **selector**. It creates or deletes Pods to reconcile **current** vs **desired** count. **Deployments** manage ReplicaSets for you and implement **rolling updates** and **history**; a **standalone** ReplicaSet has **no rollout strategy**â€”changing the template is awkward (often delete/recreate the RS or run a one-off migration). The **selector is immutable** after creation in normal workflows; if Pod labels drift from the selector, you get **orphans** or **duplicate controllers** fighting the same labels. **Never edit a Deployment-owned ReplicaSetâ€™s template directly**â€”the Deployment controller reconciles it back or you create inconsistent state.

**Prerequisites:** [2.4.3.1 Deployments](../16-deployments/README.md).

## Learning objective

- Create a **ReplicaSet** directly and see it **own** Pods via labels.
- Contrast standalone ReplicaSet with **Deployment-owned** ReplicaSets.
- Explain **selector immutability** and orphan risks.

## Why this matters

Incidents surface ReplicaSet objects: orphaned RS after bad rollouts, selector clashes, or manual pod delete churn. Knowing the controllerâ€™s job separates platform from app issues.

## Flow of this lesson

```
  ReplicaSet (selector + replicas + template)
              â”‚
              â–¼
  Pods with matching labels only
```

**Say:**

ReplicaSet is the **engine**; Deployment is the **product** most developers should drive.

## Concepts (short theory)

- Template updates on a standalone RS do not â€œrollâ€ like a Deploymentâ€”you must understand pod recreation behavior.

---

## Step 1 â€” Apply ReplicaSet and inspect

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

## Step 2 â€” Verify script

**What happens when you run this:**

Automated check for replica and ready counts.

**Say:**

If **deployment-demo** still exists from the prior lesson, both can coexistâ€”different label values.

**Run:**

```bash
chmod +x scripts/verify-replicaset-lesson.sh
./scripts/verify-replicaset-lesson.sh
```

**Expected:** Script succeeds.

## Troubleshooting

- **`ReplicaFailure` or low READY** â†’ describe RS; follow to **Events** and failing Pods
- **Too many pods** â†’ overlapping selectors with another workloadâ€”label collision
- **Changing selector fails** â†’ immutability; recreate RS and migrate pods carefully
- **Edited RS under Deployment** â†’ Deployment immediately reconcilesâ€”use **`kubectl set`** / edit **Deployment**
- **Pod `Pending`** â†’ cluster capacityâ€”not ReplicaSet-specific
- **Verify fails** â†’ wrong labels or partial delete

## Video close â€” fast validation

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

[2.4.3.3 StatefulSets](../18-statefulsets/README.md)
