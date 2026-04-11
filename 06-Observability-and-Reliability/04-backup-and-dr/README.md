# 04 Backup and DR

## Metadata
- Duration: `15 minutes`
- Difficulty: `Intermediate`
- Practical/Theory: `60/40`
- Tested on Kubernetes: `v1.30`

## Learning Objective
By the end of this lesson, you will be able to:
- Understand the abstraction differences between backing up etcd versus backing up resources with Velero.
- Construct a disaster recovery Custom Resource pointing to off-site cloud storage.

## Why This Matters in Real Jobs
When an intern accidentally runs `helm uninstall production`, your Persistent Volumes and architectural state vaporize. You must have automated, routine volume snapshotting and YAML archiving configured remotely. Velero is the industry standard for mapping live Kubernetes objects straight into AWS S3 or Google GCS buckets.

## Lab: Step-by-Step Practical

### Step 1 - Open directory
**Run:**
```bash
cd "$COURSE_DIR/06-Observability-and-Reliability/04-backup-and-dr"
```

### Step 2 - Inspect a Routine Vault

**What happens when you run this:**
You analyze a `velero.io/v1` Backup artifact. It mathematically selects the entire `prod-env` namespace, enforcing a Time-To-Live logic of `720h` (30 days) before auto-pruning.

**Run:**
```bash
cat yamls/velero-backup.yaml
```

### Step 3 - Analyze the Emergency Restoration

**What happens when you run this:**
We drop the inverse artifact. The `Restore` points blindly at a previously named `BackupName` and demands the cluster instantly retrieve the S3 bucket payload and overwrite local architecture.

**Run:**
```bash
cat yamls/velero-restore.yaml
```

## Next Lesson
[05 Incident Handling](../05-incident-handling/README.md)
