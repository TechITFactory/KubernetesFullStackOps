# 2.6.9 Volume Snapshot Classes — teaching transcript

## Intro

**VolumeSnapshotClass** parallels **StorageClass**: it names the **CSI driver** responsible for snapshots, passes **parameters** (encryption, incremental policy, array pool), and sets **deletionPolicy** (**Retain** vs **Delete**) for **VolumeSnapshotContent** when the **VolumeSnapshot** object is removed. Snapshots taken without an explicit class may use a **default** snapshot class if the platform defines one. Mismatch between **snapshot** and **volume** drivers is a common install error.

**Prerequisites:** [2.6.8 Volume Snapshots](../08-volume-snapshots/README.md).

## Flow of this lesson

```
  VolumeSnapshotClass (driver + deletionPolicy)
              │
              ▼
  VolumeSnapshot references class
              │
              ▼
  Driver creates snapshot per parameters
```

**Say:**

**Retain** protects cloud money and compliance; **Delete** keeps etcd clean—pick consciously.

## Learning objective

- Explain **VolumeSnapshotClass** fields: **driver**, **parameters**, **deletionPolicy**.
- List snapshot classes and relate them to installed CSI drivers.

## Why this matters

Orphaned **Retain** snapshot contents show up as **continuing storage bills**—operations cares about **deletionPolicy**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/06-storage/09-volume-snapshot-classes" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Snapshot class teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-6-9-volume-snapshot-classes-notes.yaml
kubectl get cm -n kube-system 2-6-9-volume-snapshot-classes-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-6-9-volume-snapshot-classes-notes` when allowed.

---

## Step 2 — List VolumeSnapshotClasses

**What happens when you run this:**

Succeeds only when snapshot CRDs exist.

**Run:**

```bash
kubectl get volumesnapshotclass 2>/dev/null | head -n 15 || true
kubectl get volumesnapshotclass -o yaml 2>/dev/null | head -n 40 || true
```

**Expected:** Classes with **DRIVER** and **DELETIONPOLICY** columns on supported clusters.

## Video close — fast validation

```bash
kubectl explain volumesnapshotclass 2>/dev/null | head -n 25 || true
```

## Troubleshooting

- **No resource type** → install snapshot CRDs ([2.6.8](../08-volume-snapshots/README.md))
- **Wrong driver** → snapshot class must match **volume** CSI driver family
- **Cannot delete snapshot** → **Retain** content requires manual cloud console cleanup
- **Parameters rejected** → array-specific validation—read driver docs
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-6-9-volume-snapshot-classes-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-6-9-volume-snapshot-classes-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.6.10 CSI Volume Cloning](../10-csi-volume-cloning/README.md)
