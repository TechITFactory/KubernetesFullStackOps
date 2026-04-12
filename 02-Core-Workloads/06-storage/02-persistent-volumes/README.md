# Persistent Volumes — teaching transcript

## Intro

**PersistentVolume (PV)** is cluster storage **capacity** described as an API object: backend (NFS, CSI, cloud disk, …), **capacity**, **access modes** (**ReadWriteOnce**, **ReadOnlyMany**, **ReadWriteMany**—interpretation is provider-specific), and **reclaim policy** (**Retain**, **Delete**, **Recycle** deprecated). **PersistentVolumeClaim (PVC)** is a **user or workload request** for storage: size and **StorageClass** (or legacy static binding to a PV). When a PVC **binds**, the Pod mounts the claim like any volume. **Static** provisioning creates PV and PVC separately; **dynamic** provisioning ([2.6.7](../07-dynamic-volume-provisioning/README.md)) creates the PV when the PVC is submitted.

**Prerequisites:** [2.6.1 Volumes](../01-volumes/README.md).

## Flow of this lesson

```
  PVC (request)  ──bind──►  PV (capacity)
        │                        │
        └──────── Pod volumeMount ┘
```

**Say:**

**Pending** PVC is the storage team’s favorite puzzle: **no PV**, **wrong class**, or **insufficient** capacity.

## Learning objective

- Contrast **PV** and **PVC** and describe **binding**.
- Read **access modes** and **reclaim policy** on a live object when present.
- Use **`kubectl get pv,pvc`** for triage.

## Why this matters

Stateful apps fail quietly when **RWO** disks attach to **two** nodes—access modes are not cosmetic labels.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/06-storage/02-persistent-volumes" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Notes land in **kube-system** when allowed.

**Run:**

```bash
kubectl apply -f yamls/2-6-2-persistent-volumes-notes.yaml
kubectl get cm -n kube-system 2-6-2-persistent-volumes-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-6-2-persistent-volumes-notes` created or RBAC blocked.

---

## Step 2 — Run inspect script

**What happens when you run this:**

Script sanity-checks **`kubectl`** and lists namespaces (baseline in repo script).

**Say:**

I extend the narrative with **`kubectl get pv,pvc`** immediately after—see Step 3.

**Run:**

```bash
bash scripts/inspect-2-6-2-persistent-volumes.sh
```

**Expected:** Script exits 0; `kubectl get ns` output shown.

---

## Step 3 — List PVs and PVCs

**What happens when you run this:**

Read-only view of cluster persistent state.

**Run:**

```bash
kubectl get pv 2>/dev/null | head -n 20 || true
kubectl get pvc -A 2>/dev/null | head -n 20 || true
```

**Expected:** Rows if objects exist; empty is normal on fresh labs.

## Video close — fast validation

```bash
kubectl get pv -o wide 2>/dev/null | head -n 10 || true
kubectl describe pvc -A 2>/dev/null | head -n 30 || true
```

## Troubleshooting

- **PVC Pending** → no matching PV or provisioner; `kubectl describe pvc`
- **Wrong access mode** → second node cannot attach **RWO**—by design for block volumes
- **Retain leaves orphaned PV** → manual reclaim after PVC delete
- **StorageClass mismatch** → PVC **storageClassName** vs available classes
- **Volume in use** → Pod still mounting—delete Pod first

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-2-6-2-persistent-volumes.sh` | Baseline kubectl check |
| `yamls/2-6-2-persistent-volumes-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-6-2-persistent-volumes-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.6.3 Projected Volumes](../03-projected-volumes/README.md)
