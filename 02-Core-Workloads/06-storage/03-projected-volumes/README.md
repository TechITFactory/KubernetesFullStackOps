# Projected Volumes — teaching transcript

## Intro

A **projected** volume mounts several **sources** into **one** directory: **configMap**, **secret**, **downwardAPI**, and **serviceAccountToken** projections share a single **mountPath** with atomic-ish updates (kubelet refreshes according to rules per source). This avoids mounting four separate volumes when one folder of files is enough—common for **TLS bundles** (cert + key from secrets) or **metadata files** next to config. Each projection can set **mode**, **optional** flags, and path **relative** to the mount.

**Prerequisites:** [2.6.2 Persistent Volumes](../02-persistent-volumes/README.md); ConfigMaps and Secrets from [07-configuration](../../07-configuration/README.md) when you teach config next.

## Flow of this lesson

```
  projected.sources[]
        │
        ├── configMap / secret items
        ├── downwardAPI
        └── serviceAccountToken
        │
        ▼
  Single volumeMount path in Pod
```

**Say:**

Projected volumes are how platforms ship **sidecar-less** “one directory of secrets” patterns.

## Learning objective

- List projection **sources** and why one volume beats many mounts.
- Relate **optional** projections to Pods that start before every key exists.

## Why this matters

Over-mounting secrets as separate volumes complicates **rotation** and path management; projection keeps the Pod spec readable.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/06-storage/03-projected-volumes" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

In-cluster notes for projected volume teaching.

**Run:**

```bash
kubectl apply -f yamls/2-6-3-projected-volumes-notes.yaml
kubectl get cm -n kube-system 2-6-3-projected-volumes-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-6-3-projected-volumes-notes` in `kube-system` when permitted.

---

## Step 2 — Find Pods using projected volumes (read-only)

**What happens when you run this:**

**grep** on live YAML is noisy on large clusters—cap with **head**.

**Say:**

In real incidents I **`kubectl get pod -o yaml`** on one known workload and search **`projected`**.

**Run:**

```bash
kubectl get pods -A -o yaml 2>/dev/null | grep -c "projected:" || true
```

**Expected:** Count (may be `0`); informational only.

## Video close — fast validation

```bash
kubectl explain pod.spec.volumes.projected 2>/dev/null | head -n 25 || kubectl explain pod.spec.volumes 2>/dev/null | head -n 20
```

## Troubleshooting

- **Projection not found on old cluster** → upgrade or use separate volume mounts
- **Permission denied on token path** → **serviceAccountToken** **audience** / **expirationSeconds** mis-set
- **Missing optional key** → Pod fails if not marked **optional: true**
- **Huge projected volume** → many keys—watch inode and size limits
- **`Forbidden` notes apply** → teach offline

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-6-3-projected-volumes-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-6-3-projected-volumes-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.6.4 Ephemeral Volumes](../04-ephemeral-volumes/README.md)
