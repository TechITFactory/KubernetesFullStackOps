# Storage Classes — teaching transcript

## Intro

A **StorageClass** names a **provisioning policy**: **provisioner** (often a **CSI** driver endpoint), **parameters** (disk type, IOPS, encryption flags), **reclaimPolicy** applied to dynamically created PVs, **volumeBindingMode** (**Immediate** vs **WaitForFirstConsumer**—scheduling interaction), and **allowVolumeExpansion**. Marking one class **`storageclass.kubernetes.io/is-default-class: "true"`** makes PVCs without **`storageClassName`** land on that tier. Operators tune **gold/silver/bronze** tiers here; developers usually only pick **`storageClassName`** on PVCs.

**Prerequisites:** [2.6.4 Ephemeral Volumes](../04-ephemeral-volumes/README.md).

## Flow of this lesson

```
  StorageClass (provisioner + params)
              │
              ▼
  PVC references storageClassName
              │
              ▼
  Dynamic PV inherits class behavior
```

**Say:**

**WaitForFirstConsumer** delays binding until the Pod is schedulable—fixes wrong-AZ volume issues on some clouds.

## Learning objective

- Read **StorageClass** fields: **provisioner**, **parameters**, **volumeBindingMode**, **allowVolumeExpansion**.
- Identify the **default** StorageClass in a cluster.

## Why this matters

Wrong **StorageClass** is cheaper and slower—or faster and non-replicated—than operators intended; this object is the contract.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/06-storage/05-storage-classes" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Notes for StorageClass teaching.

**Run:**

```bash
kubectl apply -f yamls/2-6-5-storage-classes-notes.yaml
kubectl get cm -n kube-system 2-6-5-storage-classes-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-6-5-storage-classes-notes` in `kube-system` when allowed.

---

## Step 2 — Run inspect script

**What happens when you run this:**

Baseline **`kubectl`** check from repo script.

**Run:**

```bash
bash scripts/inspect-2-6-5-storage-classes.sh
```

**Expected:** Script succeeds; namespace list printed.

---

## Step 3 — List and describe StorageClasses

**What happens when you run this:**

Shows **provisioner** and **default** annotations.

**Run:**

```bash
kubectl get storageclass -o wide 2>/dev/null | head -n 20 || true
kubectl get storageclass -o yaml 2>/dev/null | head -n 50 || true
```

**Expected:** At least cluster metadata; empty if no classes (unusual on managed K8s).

## Video close — fast validation

```bash
kubectl get storageclass
kubectl explain storageclass 2>/dev/null | head -n 20
```

## Troubleshooting

- **No default class** → PVCs without **storageClassName** stay **Pending** on some setups
- **Provisioner not running** → CSI driver pods unhealthy
- **Expansion fails** → **allowVolumeExpansion** false or driver unsupported
- **Immediate binding wrong zone** → switch to **WaitForFirstConsumer** with guidance from cloud docs
- **`Forbidden` notes** → offline teaching

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-2-6-5-storage-classes.sh` | Baseline kubectl check |
| `yamls/2-6-5-storage-classes-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-6-5-storage-classes-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.6.6 Volume Attributes Classes](../06-volume-attributes-classes/README.md)
