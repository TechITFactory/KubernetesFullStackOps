# Managing Workloads — teaching transcript

## Intro

Day-2 operations are mostly **imperative** verbs backed by the same controllers you already studied. **`kubectl scale`** changes **replicas** on a Deployment (or other scalable resource). **`kubectl rollout status`**, **`pause`**, **`resume`**, and **`undo`** manipulate **Deployment** progress and revision pointers. **`kubectl set image`** updates the **pod template**’s image, which creates a **new ReplicaSet** and performs a **rolling update** under default strategy. After emergency fixes, **backport the manifest** in Git so **desired state** matches the cluster. **Multi-workload namespaces** benefit from consistent **labels** and **`kubectl get all -l`** style filtering—know that **`get all`** does not literally mean every resource type.

**Prerequisites:** [2.4.3.1 Deployments](../15-workload-management/16-deployments/README.md).

## Learning objective

- **Scale** a Deployment, **watch** rollout status, and read **`kubectl rollout history`**.
- Use **`kubectl set image`** and **`kubectl rollout undo`** safely.
- Relate each operation to **ReplicaSets** underneath.
- Mention **`rollout pause` / `resume`** for change freezes.

## Why this matters

Day-2 work is image bumps, emergency rollback, scale for traffic, and paused rollouts during freezes—this lesson wires verbs to observable state.

## Flow of this lesson

```
  kubectl scale / set image
              │
              ▼
  Deployment spec changes
              │
              ▼
  New ReplicaSet + rolling pod replacement
              │
              ▼
  rollout history records revision
```

**Say:**

**History** is not a full audit trail—pair kubectl with **Git** and **registry** metadata.

## Concepts (short theory)

- **`kubectl rollout status`** waits for the **current** change—not a permanent health guarantee.

---

## Step 1 — Run manage demo script

**What happens when you run this:**

**`manage-workloads-demo.sh`** applies a **2-replica** nginx Deployment, **scales to 3**, bumps image **1.27 → 1.26**, prints **history**, then **undoes** to return to **nginx:1.27** with **3** replicas.

**Say:**

I narrate that **undo** jumps the Deployment’s template pointer—watch **ReplicaSet** ages in another terminal.

**Run:**

```bash
chmod +x scripts/manage-workloads-demo.sh scripts/verify-manage-workloads-lesson.sh
./scripts/manage-workloads-demo.sh
```

**Expected:** Script completes without errors; Deployment ends at **3** replicas, **nginx:1.27**.

---

## Step 2 — Verify script

**What happens when you run this:**

Asserts post-conditions expected by **module verify** with **`--labs`**.

**Run:**

```bash
./scripts/verify-manage-workloads-lesson.sh
```

**Expected:** Script succeeds.

---

## Step 3 — Repeat from scratch (optional)

**What happens when you run this:**

Deletes the Deployment and reruns the demo for a clean recording.

**Say:**

Use **`--ignore-not-found`** so a second take does not fail.

**Run:**

```bash
kubectl delete deployment manage-workloads-demo --ignore-not-found 2>/dev/null || true
./scripts/manage-workloads-demo.sh
```

**Expected:** Fresh demo run.

## Troubleshooting

- **`rollout status` hangs** → image pull or probes—`describe deploy` and **ReplicaSet** **Events**
- **`undo` surprises** → only knows **revision** stack—verify **history** first
- **Scale resets in GitOps** → declarative sync overwrites replicas—fix Helm values or Kustomize
- **`set image` typo** → new **ImagePullBackOff** rollout—undo quickly
- **`rollout pause` forgotten** → Deployment stuck mid-rollout—`resume` after fix
- **Verify script fails** → ensure demo script finished; check **labels** `app=manage-workloads-demo`

## Video close — fast validation

```bash
kubectl get deploy manage-workloads-demo -o wide
kubectl rollout history deployment/manage-workloads-demo
kubectl get rs -l app=manage-workloads-demo
kubectl get pods -l app=manage-workloads-demo -o wide
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/manage-workloads-demo.yaml` | Baseline Deployment (nginx:1.27, replicas: 2) |
| `scripts/manage-workloads-demo.sh` | Scale, image change, history, undo |
| `scripts/verify-manage-workloads-lesson.sh` | Post-demo assertions |
| `yamls/failure-troubleshooting.yaml` | Rollout pause, scaling, rollback drills |

## Cleanup

```bash
kubectl delete deployment manage-workloads-demo --ignore-not-found 2>/dev/null || true
```

## Next

[2.5 Services, Load Balancing, and Networking](../../05-services-load-balancing-and-networking/README.md)
