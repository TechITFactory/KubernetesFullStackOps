# 2.4.3.6 Automatic Cleanup for Finished Jobs — teaching transcript

## Metadata

- Duration: ~12 min (+ up to ~3 min wait for TTL deletion)
- Difficulty: Beginner
- Practical/Theory: 70/30

## Learning objective

By the end of this lesson you will be able to:

- Use **`ttlSecondsAfterFinished`** so finished Jobs do not accumulate forever in etcd and in `kubectl get jobs`.
- Explain that cleanup is performed by a **controller** after the Job reaches a terminal state — not instant on container exit.
- Recognize when TTL is the wrong tool (you still need **history** for audits — combine with external logging or lower limits).

## Why this matters in real jobs

CI namespaces and batch-heavy clusters can hold **thousands** of finished Job objects. That slows list calls, fills the API, and confuses operators. TTL is the built-in “garbage collection” knob for **finished** Jobs.

## Prerequisites

- [2.4.3.5 Jobs](../2.4.3.5-jobs/README.md)
- Cluster with **TTLAfterFinished** enabled (default on current Kubernetes versions).

## Concepts (short theory)

- **`ttlSecondsAfterFinished`** starts counting after the Job is **Complete** or **Failed**.
- The **Job controller** removes the Job object (and usually child Pods per policy); timing is **eventually consistent** — do not rely on sub-second deletion.
- TTL does not replace **Pod log shipping** — if you need logs after deletion, aggregate to Loki/CloudWatch/etc. first.

## Visual — finish, wait, delete

```mermaid
flowchart LR
  J[Job running]
  F[Finished]
  T[TTL timer]
  X[API object removed]
  J --> F
  F --> T
  T --> X
```

## Lab — Quick Start

**What happens when you run this:**  
The Job runs `echo cleanup demo`, becomes **Complete**, then **`ttlSecondsAfterFinished: 60`** tells the control plane to delete the Job roughly a minute later. While waiting, you can still `describe` the Job; after TTL, `kubectl get job` shows it gone.

```bash
kubectl apply -f yamls/job-ttl-demo.yaml
kubectl wait --for=condition=complete job/job-ttl-demo --timeout=120s
kubectl get job job-ttl-demo -o jsonpath='{.spec.ttlSecondsAfterFinished}{"\n"}'
# Within ~TTL seconds after complete, the Job disappears:
kubectl get job job-ttl-demo 2>&1 || true
```

**Verify (includes wait for deletion):**

```bash
chmod +x scripts/verify-job-ttl-lesson.sh
./scripts/verify-job-ttl-lesson.sh
```

## Transcript — short narrative

### Hook

Yesterday’s Job is not tomorrow’s debugging signal — it is clutter. TTL makes **retention** explicit in the manifest instead of in a forgotten cron that deletes old Jobs.

### Not a substitute for limits

**Say:** Pair TTL with **`successfulJobsHistoryLimit`** on **CronJobs** (next lesson) so scheduled work does not create unbounded Job history either.

### Cleanup (optional)

If the Job still exists:

```bash
kubectl delete -f yamls/job-ttl-demo.yaml --ignore-not-found
```

## Video close — fast validation

While the Job exists after completion:

```bash
kubectl get job job-ttl-demo -o wide 2>/dev/null || echo "Job already TTL-deleted"
kubectl get events -n default --field-selector involvedObject.name=job-ttl-demo --sort-by=.lastTimestamp | tail -n 15
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/job-ttl-demo.yaml` | Job with `ttlSecondsAfterFinished: 60` |
| `yamls/failure-troubleshooting.yaml` | TTL controller delays / feature gate issues |
| `scripts/verify-job-ttl-lesson.sh` | Complete → assert TTL → wait until Job removed |

## Failure troubleshooting asset

- `yamls/failure-troubleshooting.yaml` — TTL controller delays and retention issues.

## Next

[2.4.3.7 CronJob](../2.4.3.7-cronjob/README.md)
