# Automatic Cleanup for Finished Jobs — teaching transcript

## Intro

**`ttlSecondsAfterFinished`** tells the control plane to **delete a finished Job** (and dependent Pods per garbage-collection rules) after a **TTL window** counted from when the Job reaches **Complete** or **Failed**. Cleanup is **asynchronous**—do not assert sub-second deletion in automation. TTL complements **manual** `kubectl delete` and **CronJob** retention: **`successfulJobsHistoryLimit`** and **`failedJobsHistoryLimit`** trim how many **finished Jobs** from a CronJob remain listed—use those for **schedule-driven** noise, TTL for **one-shot** Jobs you do not want in etcd at all.

**Prerequisites:** [2.4.3.5 Jobs](../20-jobs/README.md); cluster with **TTLAfterFinished** enabled (default on current Kubernetes).

## Learning objective

- Use **`ttlSecondsAfterFinished`** to prevent unbounded Job accumulation.
- Explain that deletion is **controller-driven** and **eventually consistent**.
- Pair TTL with **CronJob history limits** for scheduled workloads.

## Why this matters

CI namespaces and batch clusters can hold thousands of finished Jobs—slowing **`kubectl get`** and confusing operators.

## Flow of this lesson

```
  Job Running
      │
      ▼
  Complete or Failed
      │
      ▼
  TTL timer starts
      │
      ▼
  Job + pods garbage-collected (eventually)
```

**Say:**

TTL is not log retention—**aggregate logs** before deletion if audits require them.

## Concepts (short theory)

- TTL starts **after** terminal condition—while **Active**, no timer.

---

## Step 1 — Apply TTL Job and wait for complete

**What happens when you run this:**

Job finishes **`echo cleanup demo`**, then roughly **60s** later the object disappears (timing varies).

**Say:**

I loop **`kubectl get job`** gently on camera to show **eventual** deletion without busy-wait spam.

**Run:**

```bash
kubectl apply -f yamls/job-ttl-demo.yaml
kubectl wait --for=condition=complete job/job-ttl-demo --timeout=120s
kubectl get job job-ttl-demo -o jsonpath='{.spec.ttlSecondsAfterFinished}{"\n"}'
kubectl get job job-ttl-demo 2>&1 || true
```

**Expected:** TTL field prints `60`; after the window, `get job` may show **NotFound**.

---

## Step 2 — Verify script (waits for deletion)

**What happens when you run this:**

Script completes the Job, asserts TTL field, waits until API returns **NotFound**.

**Run:**

```bash
chmod +x scripts/verify-job-ttl-lesson.sh
./scripts/verify-job-ttl-lesson.sh
```

**Expected:** Script succeeds.

## Troubleshooting

- **TTL ignored** → **TTLAfterFinished** feature disabled on ancient clusters
- **Job stuck before complete** → TTL never starts—debug pod like any Job
- **Pods remain after Job deleted** → check **ownerReferences** and **finalizers** (unusual)
- **Need audit trail** → external logging + shorter TTL, not infinite Job list
- **Verify script timeout** → slow API; increase wait in script or cluster load
- **Race in tests** → `get` immediately after complete still shows Job—expected

## Video close — fast validation

While the Job exists after completion:

```bash
kubectl get job job-ttl-demo -o wide 2>/dev/null || echo "Job already TTL-deleted"
kubectl get events -n default --field-selector involvedObject.name=job-ttl-demo --sort-by=.lastTimestamp | tail -n 15 2>/dev/null || true
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/job-ttl-demo.yaml` | Job with `ttlSecondsAfterFinished: 60` |
| `yamls/failure-troubleshooting.yaml` | TTL controller delays / feature gate issues |
| `scripts/verify-job-ttl-lesson.sh` | Complete → assert TTL → wait until Job removed |

## Cleanup

```bash
kubectl delete -f yamls/job-ttl-demo.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.3.7 CronJob](../22-cronjob/README.md)
