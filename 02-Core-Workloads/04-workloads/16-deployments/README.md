# 2.4.3.1 Deployments â€” teaching transcript

## Intro

A **Deployment** declares **desired replicas** and a **Pod template**. The **Deployment controller** creates or updates a **ReplicaSet** whose **selector** and **template** match; the ReplicaSet then creates Pods. When you change the **pod template** (image, env, labels inside the template), the Deployment starts a **rolling update**: it brings up Pods under a **new ReplicaSet** and scales down the old one according to **`strategy.rollingUpdate`**: **`maxSurge`** (extra pods above desired during rollout) and **`maxUnavailable`** (how many may be down). **`kubectl rollout status`** waits until **available** minimums are met; **`kubectl rollout history`** lists **revisions**; **`kubectl rollout undo`** rolls back to a previous revision. Old ReplicaSets are **retained** for rollback up to **`revisionHistoryLimit`**. This is the default pattern for **stateless** apps.

**Prerequisites:** [2.4.1.1 Pod Lifecycle](../../01-pods/02-pod-lifecycle/README.md) recommended.

## Learning objective

- Create a **Deployment**, watch **rollout** to available, and list **ReplicaSets** owned by it.
- Use **`kubectl rollout history`** before discussing rollback.
- Explain why **template changes** create a **new ReplicaSet** instead of patching running Pods in place.
- Interpret **`maxSurge`** / **`maxUnavailable`** at a high level.

## Why this matters

Most stateless services run behind Deployments. Rollouts, image bumps, and â€œreplicas stuck at 0â€ surface through Deployment and ReplicaSet status.

## Flow of this lesson

```
  Deployment spec (replicas + template)
              â”‚
              â–¼
  ReplicaSet (current revision)
              â”‚
              â”œâ”€â”€â–º Pods v1  (scale down during rollout)
              â””â”€â”€â–º Pods v2  (scale up, new template)
```

**Say:**

You never â€œmutate a running containerâ€™s imageâ€ in placeâ€”the controller **replaces** Pods using the new template.

## Concepts (short theory)

- **Available** means ready pods meet minimum availability rules on the Deployment (defaults allow endpoints once readiness passes).
- **Changing the pod template** increments revision metadata and shifts traffic-capable pods as readiness allows.

---

## Step 1 â€” Apply Deployment and wait for rollout

**What happens when you run this:**

The controller creates a ReplicaSet and two **nginx:1.27** Pods; **`rollout status`** blocks until the Deployment reports success.

**Say:**

I watch **`kubectl get rs`** in a second terminal during teaching to see **desired** shift between generations after an image change (homework).

**Run:**

```bash
kubectl apply -f yamls/deployment-demo.yaml
kubectl rollout status deployment/deployment-demo --timeout=120s
kubectl get deploy,pods -l app=deployment-demo
kubectl get rs -l app=deployment-demo
```

**Expected:** `AVAILABLE` equals desired (2), two pods `Running` and `READY`, one primary ReplicaSet with desired=2.

---

## Step 2 â€” Run verify script

**What happens when you run this:**

Script waits for **Available** and asserts replica counts.

**Say:**

CI uses the same script so regressions in demo YAML are caught early.

**Run:**

```bash
chmod +x scripts/verify-deployments-lesson.sh
./scripts/verify-deployments-lesson.sh
```

**Expected:** Script exits successfully.

## Troubleshooting

- **`ProgressDeadlineExceeded`** â†’ stuck rollout; check **image pull**, **probes**, and **Events** on ReplicaSet and Pods
- **Two ReplicaSets both non-zero** â†’ normal mid-rollout; use **`kubectl rollout status`**
- **`ImagePullBackOff`** â†’ registry auth or typo in template image
- **No endpoints during rollout** â†’ **`maxUnavailable`** too aggressive with single replicaâ€”raise replicas or tune strategy
- **`rollout history` empty** â†’ **`revisionHistoryLimit`** may be 0; not recommended for rollback practice
- **Verify script fails** â†’ wrong namespace or leftover objects from partial cleanup

## Video close â€” fast validation

**What happens when you run this:**

Deployment-wide view plus revision listâ€”read-only after changes.

**Say:**

I read the **REVISION** column aloud so rollback vocabulary lands.

```bash
kubectl get deploy deployment-demo -o wide
kubectl rollout history deployment/deployment-demo
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/deployment-demo.yaml` | Two-replica nginx Deployment |
| `yamls/failure-troubleshooting.yaml` | Rollout and image failures |
| `scripts/verify-deployments-lesson.sh` | Waits for Available; checks replica counts |

## Cleanup

```bash
kubectl delete -f yamls/deployment-demo.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.3.2 ReplicaSet](../17-replicaset/README.md)
