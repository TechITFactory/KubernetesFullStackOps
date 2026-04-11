# 2.6.8 Volume Snapshots — teaching transcript

## Intro

A **VolumeSnapshot** captures a **point-in-time** copy of a **PVC’s** backing volume—when the **CSI snapshot** controller and driver support it. **VolumeSnapshotContent** is the cluster-level binding object (similar to PV vs PVC). Snapshots enable **backup**, **restore**, and **clone** workflows ([2.6.10](../10-csi-volume-cloning/README.md)). You need **VolumeSnapshot CRDs**, **snapshot controller**, and a driver with **CREATE_SNAPSHOT** capability—**`kubectl get volumesnapshot`** fails if the API is not installed.

**Prerequisites:** [2.6.7 Dynamic Volume Provisioning](../07-dynamic-volume-provisioning/README.md).

## Flow of this lesson

```
  Bound PVC (CSI volume)
        │
        ▼
  VolumeSnapshot + VolumeSnapshotClass
        │
        ▼
  VolumeSnapshotContent (driver-specific handle)
```

**Say:**

Snapshots are **not** Kubernetes backups by themselves—you still need **restore drills** and off-cluster copies.

## Learning objective

- Name **VolumeSnapshot**, **VolumeSnapshotContent**, and their relationship to a **source PVC**.
- Check whether snapshot APIs are installed on a cluster.

## Why this matters

Compliance and DR reviews ask for **RPO**; snapshots are the technical primitive many teams rely on before vendor backup apps.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/06-storage/08-volume-snapshots" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Snapshot teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-6-8-volume-snapshots-notes.yaml
kubectl get cm -n kube-system 2-6-8-volume-snapshots-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-6-8-volume-snapshots-notes` when RBAC allows.

---

## Step 2 — Run inspect script

**What happens when you run this:**

Baseline **`kubectl`** check from repo.

**Run:**

```bash
bash scripts/inspect-2-6-8-volume-snapshots.sh
```

**Expected:** Script exits 0.

---

## Step 3 — List snapshot objects if API exists

**What happens when you run this:**

**grep** for snapshot API resources, then list objects.

**Run:**

```bash
kubectl api-resources | grep -i volumesnapshot || true
kubectl get volumesnapshot -A 2>/dev/null | head -n 15 || true
kubectl get volumesnapshotcontent 2>/dev/null | head -n 10 || true
```

**Expected:** Tables when CRDs installed; errors acceptable when not.

## Video close — fast validation

```bash
kubectl get volumesnapshot -A 2>/dev/null || true
kubectl get volumesnapshotcontent 2>/dev/null || true
```

## Troubleshooting

- **CRD not found** → install **external-snapshotter** components matching your K8s minor
- **Snapshot stuck** → driver does not support source volume type
- **Restore wrong data** → crash-consistent vs app-consistent—coordinate with **quiesce**
- **Deletion stuck** → **VolumeSnapshotContent** finalizers and driver delete order
- **Wrong snapshot class** → driver-specific **parameters**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-2-6-8-volume-snapshots.sh` | Baseline kubectl check |
| `yamls/2-6-8-volume-snapshots-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-6-8-volume-snapshots-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.6.9 Volume Snapshot Classes](../09-volume-snapshot-classes/README.md)
