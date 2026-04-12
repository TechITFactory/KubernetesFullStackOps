# Jobs — teaching transcript

## Intro

A **Job** runs one or more Pods **to completion**. **`completions`** is how many **successful** finishes you need; **`parallelism`** is how many Pods may run at once—together they control **batch throughput**. If pods fail, the Job retries until **`backoffLimit`** is exceeded, then the Job is **Failed**. **`activeDeadlineSeconds`** caps total runtime—safety valve for runaway jobs. **`restartPolicy`** on the Pod template must be **`OnFailure`** or **`Never`** (never **`Always`**—a completing container would restart forever). **`kubectl wait --for=condition=complete`** blocks until success; **`kubectl logs job/...`** follows the primary pod’s logs when one pod represents the Job.

**Prerequisites:** [2.4.3.4 DaemonSet](../19-daemonset/README.md).

## Learning objective

- Contrast **Jobs** with long-running **Deployment** / **DaemonSet** workloads.
- Use **`kubectl wait --for=condition=complete`** and Job **conditions** in `describe`.
- Explain **`completions`**, **`parallelism`**, **`backoffLimit`**, and **`activeDeadlineSeconds`**.
- Choose valid **`restartPolicy`** values for batch pods.

## Why this matters

Migrations, ETL, CI tasks, and admin scripts are often Jobs. Wrong **`backoffLimit`** or **`restartPolicy`** causes silent retries or stuck pods.

## Flow of this lesson

```
  Job creates Pod(s)
        │
        ├── success → toward completions
        └── failure → retry until backoffLimit
        │
        ▼
  Complete=True  or  Failed=True
```

**Say:**

Debug Jobs by **exit codes** first, then **Events**—not readiness probes.

## Concepts (short theory)

- **`ttlSecondsAfterFinished`** is covered in [2.4.3.6](../21-automatic-cleanup-for-finished-jobs/README.md)—this demo leaves the Job for inspection.

---

## Step 1 — Run Job to completion

**What happens when you run this:**

Single Pod runs **`echo hello from job`** with **`restartPolicy: Never`**; on exit 0 the Job sets **Complete**.

**Say:**

Parallel Jobs are the same object with bigger **parallelism**—draw the completions bar on a whiteboard.

**Run:**

```bash
kubectl apply -f yamls/job-demo.yaml
kubectl wait --for=condition=complete job/job-demo --timeout=120s
kubectl logs job/job-demo
```

**Expected:** Log contains `hello from job`; `kubectl get job job-demo` shows `COMPLETIONS 1/1`.

---

## Step 2 — Verify script

**What happens when you run this:**

Waits for **Complete** and checks logs when available.

**Run:**

```bash
chmod +x scripts/verify-jobs-lesson.sh
./scripts/verify-jobs-lesson.sh
```

**Expected:** Script succeeds.

## Troubleshooting

- **Job never completes** → `describe job` for **BackoffLimitExceeded** or stuck **Active**
- **`activeDeadlineSeconds` exceeded** → Job **Failed** with deadline reason—increase or fix workload
- **Wrong restartPolicy** → API reject or endless restarts—use **Never** / **OnFailure**
- **Indexed Job confusion** → completions >1 requires **completionMode** and template behavior per docs
- **Logs empty** → select pod with **`kubectl logs job/name`** vs **`kubectl logs pod`**
- **Parallelism overloads downstream** → lower **parallelism** or add client-side throttling

## Video close — fast validation

```bash
kubectl get job job-demo
kubectl describe job job-demo | sed -n '/Conditions:/,/Events:/p'
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/job-demo.yaml` | Single-completion Job (busybox echo) |
| `yamls/failure-troubleshooting.yaml` | Backoff and restart policy drills |
| `scripts/verify-jobs-lesson.sh` | Waits for Complete; checks logs when available |

## Cleanup

```bash
kubectl delete -f yamls/job-demo.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.3.6 Automatic Cleanup for Finished Jobs](../21-automatic-cleanup-for-finished-jobs/README.md)
