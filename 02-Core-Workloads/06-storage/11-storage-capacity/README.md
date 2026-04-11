# 2.6.11 Storage Capacity — teaching transcript

## Intro

**CSIStorageCapacity** objects expose **available capacity** per **StorageClass** and topology segment (node or zone) as reported by **CSI** drivers that support the **storage capacity** tracking feature. The scheduler can use this information to **avoid** placing a Pod that needs a huge PVC on a node where the array cannot satisfy the claim—reducing **Pending** PVC churn. This is **optional** in the ecosystem: many clusters omit these objects entirely. **`kubectl get csistoragecapacity`** verifies whether your platform publishes them.

**Prerequisites:** [2.6.10 CSI Volume Cloning](../10-csi-volume-cloning/README.md); [2.6.5 Storage Classes](../05-storage-classes/README.md).

## Flow of this lesson

```
  CSI driver reports free space per topology + StorageClass
              │
              ▼
  CSIStorageCapacity objects in API
              │
              ▼
  Scheduler may filter nodes (when feature enabled end-to-end)
```

**Say:**

Without driver support, **CSIStorageCapacity** stays empty—do not assume every cluster has it.

## Learning objective

- Explain why **CSIStorageCapacity** exists and what consumes it.
- Detect whether capacities are published on your cluster.

## Why this matters

Large **StatefulSets** plus thin-provisioned arrays create **last-minute** bind failures—capacity tracking reduces surprise **Pending** pods at scale.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/06-storage/11-storage-capacity" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Storage capacity teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-6-11-storage-capacity-notes.yaml
kubectl get cm -n kube-system 2-6-11-storage-capacity-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-6-11-storage-capacity-notes` when allowed.

---

## Step 2 — List CSIStorageCapacity

**What happens when you run this:**

API may be missing on older clusters.

**Run:**

```bash
kubectl api-resources | grep -i csistoragecapacity || true
kubectl get csistoragecapacity -A 2>/dev/null | head -n 20 || true
```

**Expected:** Rows with **CAPACITY**, **STORAGECLASS**, **TOPOLOGY** when populated.

## Video close — fast validation

```bash
kubectl get csistoragecapacity -o wide 2>/dev/null | head -n 15 || true
```

## Troubleshooting

- **Empty list** → driver does not publish or feature gate off
- **Stale capacity** → refresh intervals vs reality—treat as **hint** not **accounting**
- **Scheduler ignores** → kube-scheduler **featureConfig** / version matrix
- **Wrong topology** → labels on nodes vs CSI topology keys
- **`Forbidden` notes** → offline only

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-6-11-storage-capacity-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-6-11-storage-capacity-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.6.12 Node-specific Volume Limits](../12-node-specific-volume-limits/README.md)
