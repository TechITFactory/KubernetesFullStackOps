# Volume Attributes Classes — teaching transcript

## Intro

**VolumeAttributesClass (VAC)** is a newer API for describing **mutable or selectable volume attributes** separate from the **StorageClass** provisioning profile—think **IOPS/throughput tiers** or driver-specific knobs that may change over a volume’s life without redefining the entire **StorageClass**. Availability depends on **Kubernetes version**, **feature gates**, and **CSI driver** support; many clusters will not expose **`volumeattributesclass`** resources yet. Treat this lesson as **forward-looking**: **`kubectl explain volumeattributesclass`** and **`kubectl get volumeattributesclass`** validate whether your platform implements it.

**Prerequisites:** [2.6.5 Storage Classes](../05-storage-classes/README.md).

## Flow of this lesson

```
  StorageClass (provision / bind profile)
        │
        └── VolumeAttributesClass (driver attribute profile) — when supported
                    │
                    ▼
              PVC / volume may reference VAC (per platform)
```

**Say:**

If **`kubectl get volumeattributesclass`** returns **NotFound**, the API is not registered—skip deep demos.

## Learning objective

- Explain **VolumeAttributesClass** in one sentence relative to **StorageClass**.
- Discover whether the API exists on your cluster.

## Why this matters

FinOps and performance teams want **tier changes** without reprovisioning entire volumes—this API is the direction of travel for some drivers.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/06-storage/06-volume-attributes-classes" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

VAC teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-6-6-volume-attributes-classes-notes.yaml
kubectl get cm -n kube-system 2-6-6-volume-attributes-classes-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-6-6-volume-attributes-classes-notes` when RBAC allows.

---

## Step 2 — Probe VolumeAttributesClass API

**What happens when you run this:**

**CRD/API** presence check—harmless when missing.

**Run:**

```bash
kubectl api-resources | grep -i volumeattributesclass || true
kubectl get volumeattributesclass 2>/dev/null | head -n 10 || true
```

**Expected:** Resource lines and objects, or empty / error on unsupported clusters.

## Video close — fast validation

```bash
kubectl explain volumeattributesclass 2>/dev/null | head -n 25 || true
```

## Troubleshooting

- **Resource type unknown** → upgrade cluster or wait for platform rollout
- **Driver ignores VAC** → CSI feature parity matrix
- **Confused with StorageClass** → provisioning vs attribute overlay—narrate distinction
- **`Forbidden`** → RBAC on new API group
- **Notes only** → teach concept from ConfigMap text when API absent

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-6-6-volume-attributes-classes-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-6-6-volume-attributes-classes-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.6.7 Dynamic Volume Provisioning](../07-dynamic-volume-provisioning/README.md)
