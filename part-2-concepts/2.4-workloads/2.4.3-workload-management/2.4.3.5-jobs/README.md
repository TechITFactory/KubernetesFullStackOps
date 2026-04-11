# 2.4.3.5 Jobs — teaching transcript

## Metadata

- Duration: ~12 min
- Difficulty: Beginner
- Practical/Theory: 75/25

## Learning objective

By the end of this lesson you will be able to:

- Contrast **run-to-completion** Jobs with long-running controllers (Deployment, DaemonSet).
- Use **`kubectl wait --for=condition=complete`** and Job **conditions** in `describe` output.
- Choose a sensible **`restartPolicy`** for batch pods (`Never` or `OnFailure` — not `Always`).

## Why this matters in real jobs

Migrations, ETL, CI runners on Kubernetes, and one-off admin tasks are often **Jobs**. Misconfigured **`backoffLimit`** or wrong **restartPolicy** produces silent retries or stuck pods — the Job status fields are where you debug first.

## Prerequisites

- [2.4.3.4 DaemonSet](../2.4.3.4-daemonset/README.md)

## Concepts (short theory)

- A **Job** creates one or more Pods until **completions** succeed (default `completions: 1`, `parallelism: 1`).
- **`activeDeadlineSeconds`**, **`backoffLimit`**, and **Pod failure** interact: read `kubectl describe job` when a Job never reaches `Complete`.
- **`ttlSecondsAfterFinished`** (optional) cleans up finished Job objects — not set in this demo, so the Job remains for inspection.

## Visual — Job to completion

```mermaid
flowchart LR
  J[Job job-demo]
  P[Pod runs once]
  OK[Exit 0]
  CMP[Complete=True]
  J --> P
  P --> OK
  OK --> CMP
```

## Lab — Quick Start

**What happens when you run this:**  
The Job creates a Pod running `echo hello from job` with **`restartPolicy: Never`**. When the container exits successfully, the Job controller sets **`Complete=True`** and retains the Job object (until you delete it or TTL elapses).

```bash
kubectl apply -f yamls/job-demo.yaml
kubectl wait --for=condition=complete job/job-demo --timeout=120s
kubectl logs job/job-demo
```

**Expected:** Log line contains `hello from job`; `kubectl get job job-demo` shows `COMPLETIONS 1/1`.

**Verify:**

```bash
chmod +x scripts/verify-jobs-lesson.sh
./scripts/verify-jobs-lesson.sh
```

## Transcript — short narrative

### Hook

Everything so far assumed “keep running.” Jobs ask “**did the work finish?**” That flips debugging from readiness probes to **exit codes and backoff**.

### Parallelism (mention only)

**Say:** Increase **`parallelism`** for worker pools; **`completions`** counts how many successful finishes you need. This single-pod demo is the mental model before parallel batch patterns.

### Cleanup (optional)

```bash
kubectl delete -f yamls/job-demo.yaml --ignore-not-found
```

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

## Failure troubleshooting asset

- `yamls/failure-troubleshooting.yaml` — backoffLimit, restartPolicy, parallel Job pitfalls.

## Next

[2.4.3.6 Automatic Cleanup for Finished Jobs](../2.4.3.6-automatic-cleanup-for-finished-jobs/README.md)
