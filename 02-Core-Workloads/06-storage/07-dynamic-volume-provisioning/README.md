# 2.6.7 Dynamic Volume Provisioning — teaching transcript

## Intro

**Dynamic provisioning** creates a **PersistentVolume** automatically when a **PersistentVolumeClaim** appears and matches a **StorageClass** whose **provisioner** can allocate storage. The **CSI** driver (or legacy in-tree shim) talks to the cloud or array, returns a handle, and the control plane **binds** PVC to PV. You debug with **`kubectl describe pvc`** (events show **Provisioning**, **ExternalProvisioning**, failures) and driver logs. **WaitForFirstConsumer** delays provisioning until a Pod that uses the PVC is schedulable, reducing **wrong topology** volumes.

**Prerequisites:** [2.6.5 Storage Classes](../05-storage-classes/README.md); [2.6.2 Persistent Volumes](../02-persistent-volumes/README.md).

## Flow of this lesson

```
  PVC created (storageClassName set)
              │
              ▼
  Provisioner allocates backend volume
              │
              ▼
  PV object created + bound to PVC
              │
              ▼
  Pod mounts PVC when scheduled
```

**Say:**

**ProvisioningFailed** in **Events** is where I start—not the app container logs.

## Learning objective

- Trace **PVC → provisioner → PV → bound** for dynamic volumes.
- Interpret **`kubectl describe pvc`** events during provisioning failures.

## Why this matters

Most clusters never use **static** PVs for app teams—dynamic path is the default mental model.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/06-storage/07-dynamic-volume-provisioning" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Dynamic provisioning notes.

**Run:**

```bash
kubectl apply -f yamls/2-6-7-dynamic-volume-provisioning-notes.yaml
kubectl get cm -n kube-system 2-6-7-dynamic-volume-provisioning-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-6-7-dynamic-volume-provisioning-notes` when allowed.

---

## Step 2 — Run inspect script

**What happens when you run this:**

Repo baseline script.

**Run:**

```bash
bash scripts/inspect-2-6-7-dynamic-volume-provisioning.sh
```

**Expected:** Script exits 0.

---

## Step 3 — Correlate PVCs, PVs, and StorageClasses

**What happens when you run this:**

Read-only triage triplet.

**Run:**

```bash
kubectl get pvc -A 2>/dev/null | head -n 20 || true
kubectl get pv 2>/dev/null | head -n 20 || true
kubectl get storageclass 2>/dev/null | head -n 15 || true
```

**Expected:** Bound rows show **CLAIM** column on PVs; Pending PVCs show provisioning issues.

## Video close — fast validation

```bash
kubectl get pvc -A -o wide 2>/dev/null | head -n 15 || true
kubectl get events -A --field-selector reason=Provisioning 2>/dev/null | tail -n 10 || true
```

## Troubleshooting

- **PVC Pending + no events** → **default StorageClass** missing or webhook blocking
- **Permission denied from cloud** → IAM / managed identity on CSI controller
- **Quota** → **ResourceQuota** `requests.storage` exceeded
- **Topology** → use **WaitForFirstConsumer**; check **allowedTopologies** on StorageClass
- **Driver CrashLoop** → **csi-provisioner** sidecar logs

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-2-6-7-dynamic-volume-provisioning.sh` | Baseline kubectl check |
| `yamls/2-6-7-dynamic-volume-provisioning-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-6-7-dynamic-volume-provisioning-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.6.8 Volume Snapshots](../08-volume-snapshots/README.md)
