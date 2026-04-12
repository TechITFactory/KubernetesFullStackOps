# Backup and DR — teaching transcript

## Intro

**Kubernetes** **state** **lives** **in** **etcd** **(control** **plane)**, **PVs** **(data)**, **and** **object** **YAML** **in** **Git** **or** **registries**. **[Velero](https://velero.io/docs/)** **backs** **up** **namespaced** **resources** **and** **often** **coordinates** **volume** **snapshots** **to** **object** **storage**. **This** **lesson** **reads** **`Backup`** **and** **`Restore`** **CRs** **that** **target** **`prod-env`** **with** **a** **`ttl`** **and** **named** **`storageLocation`** **—** **do** **not** **`apply`** **unless** **Velero** **is** **installed** **and** **you** **own** **the** **bucket** **configuration**.

**Prerequisites:** [6.3 Autoscaling decisions](../03-autoscaling-decisions/README.md); [3.3 Environment separation](../../03-Packaging-and-Environments/03-environment-separation/README.md) **`prod-env` namespace** **(optional** **context)**.

## Flow of this lesson

```
  Scheduled or ad-hoc Velero Backup → object storage + snapshots
              │
              ▼
  Incident: mistaken delete or region loss
              │
              ▼
  Velero Restore references backupName → recreates scope
```

**Say:**

**Helm** **`uninstall` is** **not** **reversed** **by** **Git** **alone** **if** **nobody** **committed** **the** **chart** **state** **—** **backups** **exist** **for** **that** **class** **of** **mistake**.

## Learning objective

- **Contrast** **etcd** **snapshots** **with** **application-level** **Velero** **backups**.
- **Read** **`Backup`** **and** **`Restore`** **specs** **and** **name** **required** **external** **dependencies** **(storage** **location**, **credentials)**.

## Why this matters

**Restore** **drills** **reveal** **whether** **your** **“backup”** **was** **actually** **restorable** **—** **not** **whether** **the** **checkbox** **was** **green**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/06-Observability-and-Reliability/04-backup-and-dr" 2>/dev/null || cd .
```

## Step 1 — Inspect a Backup object

**What happens when you run this:**

**You** **read** **`daily-prod-backup`**: **`includedNamespaces: prod-env`**, **`ttl: 720h`**, **`storageLocation: aws-s3-bucket`**.

**Run:**

```bash
cat yamls/velero-backup.yaml
```

**Expected:** **`velero.io/v1` `Backup`**, **fields** **as** **above**.

---

## Step 2 — Inspect a Restore object

**What happens when you run this:**

**You** **read** **`emergency-restore`**: **`backupName: daily-prod-backup`**, **`includedNamespaces`**.

**Run:**

```bash
cat yamls/velero-restore.yaml
```

**Expected:** **`velero.io/v1` `Restore`**, **`spec.backupName`** **set**.

---

## Step 3 — Optional cluster check

**What happens when you run this:**

**Lists** **Velero** **CRDs** **if** **installed**.

**Run:**

```bash
kubectl api-resources 2>/dev/null | grep -i velero | head -n 10 || true
```

**Expected:** **`backups.velero.io`**, **`restores.velero.io`**, **etc.**, **or** **empty**.

## Video close — fast validation

**What happens when you run this:**

**No** **default** **cleanup** **—** **only** **delete** **if** **you** **applied** **these** **CRs** **yourself**.

**Run:**

```bash
kubectl delete -f yamls/velero-restore.yaml --ignore-not-found 2>/dev/null || true
kubectl delete -f yamls/velero-backup.yaml --ignore-not-found 2>/dev/null || true
```

**Expected:** **Nothing** **or** **resources** **removed**.

## Troubleshooting

- **Backup** **stuck** **`New`** → **credentials**, **BSL** **configuration**, **or** **Velero** **pod** **health**
- **Restore** **partial** → **cross-cluster** **UUID** **mismatches**, **storage** **class** **mapping**
- **Wrong** **namespace** **for** **CRs** → **samples** **use** **`velero` namespace** **—** **match** **your** **install**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/velero-backup.yaml` | **Example** **`Backup`** |
| `yamls/velero-restore.yaml` | **Example** **`Restore`** |

## Cleanup

```bash
kubectl delete -f yamls/velero-restore.yaml --ignore-not-found 2>/dev/null || true
kubectl delete -f yamls/velero-backup.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[6.5 Incident handling](../05-incident-handling/README.md)
