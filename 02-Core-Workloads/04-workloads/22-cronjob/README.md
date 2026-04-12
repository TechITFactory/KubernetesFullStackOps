# CronJob — teaching transcript

## Intro

A **CronJob** creates **Job** objects on a **cron schedule** using five fields: **minute hour day-of-month month day-of-week**. Since Kubernetes **1.27**, you can set **`spec.timeZone`** so schedules are evaluated in a **named timezone** (IANA) instead of assuming **UTC**—still confirm your **control plane** version supports it. **`concurrencyPolicy`**: **`Allow`** overlaps runs; **`Forbid`** skips a new Job if the previous is still running; **`Replace`** cancels the still-running Job to start a new one—pick based on whether overlaps are safe. **`startingDeadlineSeconds`** bounds how late a missed tick may still start—prevents huge backlogs after downtime. **`successfulJobsHistoryLimit`** and **`failedJobsHistoryLimit`** cap how many **finished Jobs** remain—pair with per-Job **TTL** from [2.4.3.6](../21-automatic-cleanup-for-finished-jobs/README.md) when you want API objects gone entirely.

**Prerequisites:** [2.4.3.6 Automatic cleanup for finished Jobs](../21-automatic-cleanup-for-finished-jobs/README.md).

## Learning objective

- Read **cron** schedule fields and relate them to controller firing behavior.
- Explain **`concurrencyPolicy`** values and **`startingDeadlineSeconds`**.
- Create a **one-off Job** from a CronJob with **`kubectl create job --from=cronjob/...`**.
- Mention **`spec.timeZone`** (1.27+) versus historical UTC defaults.

## Why this matters

CronJobs power backups and reports. Incidents appear as **missed schedules**, **overlapping runs**, or **unbounded Job lists**.

## Flow of this lesson

```
  CronJob
     │
     ├── schedule tick (timezone-aware if spec.timeZone set)
     │
     ▼
  Job object created
     │
     ▼
  Pod runs template
```

**Say:**

Always state **which clock** the cluster uses before blaming “cron drift.”

## Concepts (short theory)

- **`suspend: true`** stops future Jobs without deleting the CronJob—maintenance switch.

---

## Step 1 — Apply CronJob and inspect

**What happens when you run this:**

**`*/1 * * * *`** fires every minute with **`concurrencyPolicy: Forbid`**—slow runs block the next.

**Say:**

Open a second terminal with **`kubectl get jobs -w`** for rhythm during recording.

**Run:**

```bash
kubectl apply -f yamls/cronjob-demo.yaml
kubectl get cronjob cronjob-demo
kubectl describe cronjob cronjob-demo | sed -n '1,45p'
```

**Expected:** CronJob listed; describe shows schedule and policy fields.

---

## Step 2 — Manual Job from CronJob template

**What happens when you run this:**

**`--from=cronjob/...`** clones the pod template without waiting for the schedule.

**Say:**

This is how SREs smoke-test **command** and **image** before the next midnight run.

**Run:**

```bash
kubectl create job cj-manual-test --from=cronjob/cronjob-demo
kubectl wait --for=condition=complete job/cj-manual-test --timeout=120s
kubectl logs job/cj-manual-test
kubectl delete job cj-manual-test --ignore-not-found 2>/dev/null || true
```

**Expected:** Manual Job completes; logs match template; delete is idempotent.

---

## Step 3 — Verify script

**What happens when you run this:**

Creates and deletes a short-lived Job automatically.

**Run:**

```bash
chmod +x scripts/verify-cronjob-lesson.sh
./scripts/verify-cronjob-lesson.sh
```

**Expected:** Script succeeds.

## Troubleshooting

- **Missed schedules** → check **`startingDeadlineSeconds`**, **suspend**, and **timezone** assumptions
- **Overlapping dangerous jobs** → switch from **Allow** to **Forbid**
- **Too many Jobs listed** → lower **history** limits or add **TTL** on Job template
- **Cron syntax error** → API rejects on apply; validate with dry-run
- **Wrong local time** → set **`spec.timeZone`** on supported clusters or convert to UTC explicitly
- **Leftover `cj-verify-*` Jobs** → delete if verify script interrupted

## Video close — fast validation

```bash
kubectl get cronjob
kubectl get jobs --sort-by=.metadata.creationTimestamp | tail -n 8
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/cronjob-demo.yaml` | Every-minute CronJob, `Forbid`, history limits |
| `yamls/failure-troubleshooting.yaml` | Schedule, timezone, concurrency issues |
| `scripts/verify-cronjob-lesson.sh` | `--from=cronjob` one-shot Job + log sanity |

## Cleanup

```bash
kubectl delete -f yamls/cronjob-demo.yaml --ignore-not-found 2>/dev/null || true
kubectl delete job cj-manual-test --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.3.8 ReplicationController](../23-replicationcontroller/README.md)
