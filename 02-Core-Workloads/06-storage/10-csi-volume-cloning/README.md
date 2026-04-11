# 2.6.10 CSI Volume Cloning — teaching transcript

## Intro

**CSI volume cloning** creates a **new PVC** whose data starts as a **copy** of an existing volume, declared via **`dataSource`** on the **PersistentVolumeClaim** pointing to another **PVC** (or sometimes a **VolumeSnapshot**, driver-dependent). The **CSI** driver must advertise **CLONE_VOLUME** capability. Cloning is faster than **rsync** for large datasets when the array supports **copy-on-write** or efficient block copy. It is **not** a substitute for **application-consistent** backup unless the workload is quiesced.

**Prerequisites:** [2.6.9 Volume Snapshot Classes](../09-volume-snapshot-classes/README.md); [2.6.7 Dynamic Volume Provisioning](../07-dynamic-volume-provisioning/README.md).

## Flow of this lesson

```
  Source PVC (Bound)
        │
        ▼
  New PVC.spec.dataSource.kind = PersistentVolumeClaim
        │
        ▼
  Provisioner clones backend → new Bound PVC
```

**Say:**

I verify **clone** support in the **CSI** driver matrix before promising this in production designs.

## Learning objective

- Describe **PVC `dataSource`** used for **clone** vs **snapshot restore**.
- State **CSI** capability requirements for cloning.

## Why this matters

Clone-based **staging** and **namespace copy** workflows depend on this one field—wrong assumptions waste migration weekends.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/06-storage/10-csi-volume-cloning" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Cloning teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-6-10-csi-volume-cloning-notes.yaml
kubectl get cm -n kube-system 2-6-10-csi-volume-cloning-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-6-10-csi-volume-cloning-notes` when RBAC allows.

---

## Step 2 — Explain PVC dataSource (read-only)

**What happens when you run this:**

Shows API documentation for **`dataSource`** on claims.

**Run:**

```bash
kubectl explain pvc.spec.dataSource 2>/dev/null | head -n 30 || true
```

**Expected:** Field reference output or empty on very old `kubectl`.

## Video close — fast validation

```bash
kubectl get pvc -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"/"}{.metadata.name}{"\t"}{.spec.dataSource}{"\n"}{end}' 2>/dev/null | head -n 15 || true
```

## Troubleshooting

- **ProvisioningFailed on clone** → driver lacks **CLONE_VOLUME** or wrong **storageClass**
- **Size too small** → clone PVC must be **>=** source size (policy varies)
- **Cross-namespace** → generally unsupported for **dataSource** PVC reference—check version/docs
- **Snapshot vs clone confusion** → **dataSource** **kind** differs; driver rules differ
- **`Forbidden` apply** → offline notes

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-6-10-csi-volume-cloning-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-6-10-csi-volume-cloning-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.6.11 Storage Capacity](../11-storage-capacity/README.md)
