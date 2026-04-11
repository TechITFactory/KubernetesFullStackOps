# 2.6.12 Node-specific Volume Limits — teaching transcript

## Intro

Each node can attach only **so many** volumes—limits come from **cloud provider** quotas (for example max **EBS** attachments per **EC2** instance type), **CSI** driver design, and **kubelet** bookkeeping. When exceeded, new Pods with PVCs may **fail to attach** with events about **too many** volumes. **DaemonSets** that mount one PVC per node avoid some multi-attach issues but still hit **per-node** ceilings. Operators track **instance type**, **max count**, and **in-use** devices; developers reduce **RWO** fan-out per node.

**Prerequisites:** [2.6.11 Storage Capacity](../11-storage-capacity/README.md).

## Flow of this lesson

```
  Node + instance type / driver limits
              │
              ▼
  Volume attachments (CSI Attachment objects)
              │
              ▼
  Fail if max attachments exceeded
```

**Say:**

I correlate **VolumeAttachment** count with cloud **device** limits during “random attach errors.”

## Learning objective

- Explain **per-node volume attachment** limits as a scheduling/ops constraint.
- Use **`kubectl get volumeattachment`** for a read-only attachment inventory.

## Why this matters

“Works in dev (small nodes)” and “fails in prod (dense nodes)” often traces to **attachment** limits, not app bugs.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/06-storage/12-node-specific-volume-limits" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Node limits teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-6-12-node-specific-volume-limits-notes.yaml
kubectl get cm -n kube-system 2-6-12-node-specific-volume-limits-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-6-12-node-specific-volume-limits-notes` when RBAC allows.

---

## Step 2 — List VolumeAttachments

**What happens when you run this:**

Shows which volumes are **attached** to which nodes.

**Run:**

```bash
kubectl get volumeattachment 2>/dev/null | head -n 25 || true
```

**Expected:** Table of **ATTACHER**, **PV**, **NODE**, **ATTACHED** columns when CSI in use.

## Video close — fast validation

```bash
kubectl get volumeattachment -o wide 2>/dev/null | head -n 15 || true
kubectl get nodes -o custom-columns=NAME:.metadata.name,INSTANCE:.metadata.labels.node\\.kubernetes\\.io/instance-type 2>/dev/null | head -n 10 || true
```

## Troubleshooting

- **Attach timeout** → limit hit; **detach** stale volumes or spread workloads
- **Wrong node** → **multi-attach** not allowed for **RWO** block volumes
- **Stale VolumeAttachment** → finalizer / driver bug—vendor runbook
- **Local SSD count** → separate from network volumes—read cloud docs
- **`Forbidden`** → narrow namespace or RBAC

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-6-12-node-specific-volume-limits-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-6-12-node-specific-volume-limits-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.6.13 Local Ephemeral Storage](../13-local-ephemeral-storage/README.md)
