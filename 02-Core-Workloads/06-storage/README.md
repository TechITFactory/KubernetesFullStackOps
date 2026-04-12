# Storage — teaching transcript

## Intro

Storage in Kubernetes separates **how Pods reference disk** from **where bytes actually live**. **Volumes** mount into the Pod spec: some are **ephemeral** (lost with the Pod), some are **backed by the cloud** (PersistentVolumes), and some **project** API objects into files. **PersistentVolumeClaims** ask the cluster for storage; **PersistentVolumes** (or dynamic provisioners) satisfy those claims. **StorageClasses** describe **classes** of storage—provisioner, parameters, and default behavior—so PVCs can say “give me fast SSD” without naming a disk by hand. **CSI** drivers implement the plug-in model for snapshots, cloning, capacity tracking, and health signals. This module walks from basic volumes through provisioning, snapshots, and operational edges (capacity, limits, ephemeral quota, Windows).

**Prerequisites:** [02-Core-Workloads entry](../README.md); [Services / networking](../05-services-load-balancing-and-networking/README.md) helps for DNS and workload context before Stateful apps.

## Flow of this lesson

```
  Pod volumes (emptyDir, projections, secrets/config)
              │
              ▼
  PVC ──► PV / dynamic provisioner (StorageClass)
              │
              ▼
  Snapshots, clone, capacity, limits (CSI + API)
              │
              ▼
  Ops: ephemeral quota, health, Windows paths
```

**Say:**

I teach **volumes before PVCs** so “where did my file go?” has a clear answer: Pod lifetime vs claim lifetime.

## Learning objective

- Map **2.6.1–2.6.15** topics to the storage lifecycle from Pod mount to backup and limits.
- Run lesson labs with **`kubectl apply`** on notes YAMLs and optional **inspect** scripts where present.

## Why this matters

Data loss tickets usually mix up **ephemeral** vs **persistent** storage or **wrong StorageClass**—this module keeps those boundaries explicit.

## Children (suggested order)

1. [2.6.1 Volumes](01-volumes/README.md)
2. [2.6.2 Persistent Volumes](02-persistent-volumes/README.md)
3. [2.6.3 Projected Volumes](03-projected-volumes/README.md)
4. [2.6.4 Ephemeral Volumes](04-ephemeral-volumes/README.md)
5. [2.6.5 Storage Classes](05-storage-classes/README.md)
6. [2.6.6 Volume Attributes Classes](06-volume-attributes-classes/README.md)
7. [2.6.7 Dynamic Volume Provisioning](07-dynamic-volume-provisioning/README.md)
8. [2.6.8 Volume Snapshots](08-volume-snapshots/README.md)
9. [2.6.9 Volume Snapshot Classes](09-volume-snapshot-classes/README.md)
10. [2.6.10 CSI Volume Cloning](10-csi-volume-cloning/README.md)
11. [2.6.11 Storage Capacity](11-storage-capacity/README.md)
12. [2.6.12 Node-specific Volume Limits](12-node-specific-volume-limits/README.md)
13. [2.6.13 Local Ephemeral Storage](13-local-ephemeral-storage/README.md)
14. [2.6.14 Volume Health Monitoring](14-volume-health-monitoring/README.md)
15. [2.6.15 Windows Storage](15-windows-storage/README.md)

## Module wrap — quick validation

**What happens when you run this:** Read-only inventory of storage-related API objects (some commands no-op if CRDs are missing).

**Say:**

I run this after any lesson that created PVCs or snapshots to see what the cluster still holds.

```bash
kubectl get pv,pvc,storageclass 2>/dev/null | head -n 40
kubectl get volumesnapshot,volumesnapshotclass 2>/dev/null | head -n 20 || true
kubectl get csistoragecapacity 2>/dev/null | head -n 15 || true
kubectl get volumeattributesclass 2>/dev/null | head -n 10 || true
```

## Troubleshooting

- **`volumesnapshot` not found** → install **snapshot CRDs** and snapshot controller for your CSI driver
- **PVC `Pending`** → no **StorageClass**, no **provisioner**, or quota—`describe pvc`
- **Empty `kubectl get pv`** → no static PVs and no dynamic provisioning yet—normal on fresh clusters
- **Permission denied on `kube-system` notes** → apply skipped; teach from YAML in git
- **Wrong cluster** → `kubectl config current-context` before storage drills

## Next

[2.7 Configuration](../07-configuration/README.md)
