# 2.6.4 Ephemeral Volumes — teaching transcript

## Intro

**Ephemeral volumes** are **tied to Pod lifecycle**: classic **emptyDir** (often **node** disk or **memory** medium), **generic ephemeral volumes** (Kubernetes creates a **PVC-like** volume that is deleted with the Pod—backed by **StorageClass**), and **CSI ephemeral** inline volumes that **do not** create a separate long-lived PVC object. They suit **cache**, **scratch**, **build workspaces**, and **short-lived** stateful helpers. They are **not** a substitute for databases that must survive Pod replacement—use **PVCs** for that.

**Prerequisites:** [2.6.3 Projected Volumes](../03-projected-volumes/README.md).

## Flow of this lesson

```
  Scratch / cache need
        │
        ├── emptyDir (simple, node-scoped)
        ├── generic ephemeral volume + StorageClass
        └── CSI ephemeral inline spec
        │
        ▼
  Deleted when Pod is deleted (by design)
```

**Say:**

I contrast **ephemeral** with **PVC**: same mount UX, different **garbage collection** story.

## Learning objective

- Contrast **emptyDir**, **generic ephemeral volumes**, and **CSI ephemeral** use cases.
- Explain why ephemeral storage is wrong for durable databases.

## Why this matters

Teams lose data after restarts when they put “important” files on **emptyDir**—naming the volume type prevents that class of bug.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/06-storage/04-ephemeral-volumes" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Ephemeral volume teaching notes in **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-6-4-ephemeral-volumes-notes.yaml
kubectl get cm -n kube-system 2-6-4-ephemeral-volumes-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-6-4-ephemeral-volumes-notes` present when RBAC allows.

---

## Step 2 — Inspect StorageClasses (ephemeral provisioning context)

**What happens when you run this:**

**StorageClass** list shows what could back **generic ephemeral** volumes.

**Run:**

```bash
kubectl get storageclass 2>/dev/null | head -n 15 || true
```

**Expected:** Default `StorageClass` often marked `(default)`; may be empty on minimal clusters.

## Video close — fast validation

```bash
kubectl explain pod.spec.volumes.ephemeral 2>/dev/null | head -n 20 || true
kubectl get storageclass -o wide 2>/dev/null | head -n 10 || true
```

## Troubleshooting

- **Generic ephemeral stuck Pending** → **StorageClass** or **provisioner** missing
- **Out of disk on node** → **emptyDir** uses node filesystem—evictions follow ([2.6.13](../13-local-ephemeral-storage/README.md))
- **CSI ephemeral not supported** → driver feature matrix
- **Confuse with projected** → projected merges API projections; ephemeral is block/fs backing
- **`Forbidden` apply** → offline YAML only

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-6-4-ephemeral-volumes-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-6-4-ephemeral-volumes-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.6.5 Storage Classes](../05-storage-classes/README.md)
