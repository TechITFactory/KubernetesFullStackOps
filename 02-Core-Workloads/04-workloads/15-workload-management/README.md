# 2.4.3 Workload Management — teaching transcript

## Intro

Controllers turn **desired state** in the API into **running Pods**. A **Deployment** is the usual choice for **stateless** apps: it performs **rolling updates**, keeps **ReplicaSets** under the hood, and preserves **revision history** for rollback. The **ReplicaSet** is the mechanism that matches a **label selector** to a replica count; you normally let the Deployment own it. A **StatefulSet** adds **ordered** creation, **stable network identity**, and often **per-pod storage** via **volumeClaimTemplates**. A **DaemonSet** runs **one pod per eligible node**—think log agents, node exporters, or CNI components. **Jobs** run pods **to completion**; **CronJobs** create Jobs on a **schedule**. Together these are the workload management toolkit you will see in every cluster.

**Prerequisites:** [2.4.1.1 Pod Lifecycle](../2.4.1-pods/2.4.1.1-pod-lifecycle/README.md) recommended so Pod phases and conditions are fresh.

## Flow of this lesson

```
  Need stable identity + ordered pods + PVCs each?
        │ yes                          │ no
        ▼                                ▼
   StatefulSet                    One pod per node?
                                      │ yes → DaemonSet
                                      │ no
                                      ▼
                              Batch / schedule?
                                 │ one-shot → Job
                                 │ recurring → CronJob
                                 │ long-running stateless → Deployment
```

**Say:**

This is a decision flow for **which controller**, not a mandate to skip reading Pod specs. StatefulSet without headless Service and storage is incomplete; DaemonSet without **tolerations** often misses control-plane nodes.

## Learning objective

- Match **Deployment**, **ReplicaSet**, **StatefulSet**, **DaemonSet**, **Job**, and **CronJob** to their primary use cases.
- Follow the numbered children in order for the **core path** with verify scripts.

## Why this matters

Choosing the wrong controller shows up months later as painful migrations—especially mistaking StatefulSet ordering for “just another Deployment.”

## Children (suggested order)

1. [2.4.3.1 Deployments](2.4.3.1-deployments/README.md) — **default stateless app** (transcript + verify).
2. [2.4.3.2 ReplicaSet](2.4.3.2-replicaset/README.md) — what Deployments own under the hood (transcript + verify).
3. [2.4.3.3 StatefulSets](2.4.3.3-statefulsets/README.md) — transcript + `scripts/verify-statefulset-lesson.sh`
4. [2.4.3.4 DaemonSet](2.4.3.4-daemonset/README.md) — transcript + `scripts/verify-daemonset-lesson.sh`
5. [2.4.3.5 Jobs](2.4.3.5-jobs/README.md) — transcript + `scripts/verify-jobs-lesson.sh`
6. [2.4.3.6 Automatic Cleanup for Finished Jobs](2.4.3.6-automatic-cleanup-for-finished-jobs/README.md) — transcript + `scripts/verify-job-ttl-lesson.sh` (waits for TTL deletion)
7. [2.4.3.7 CronJob](2.4.3.7-cronjob/README.md) — transcript + `scripts/verify-cronjob-lesson.sh` (`kubectl create job --from=cronjob/...`)
8. [2.4.3.8 ReplicationController](2.4.3.8-replicationcontroller/README.md) — transcript + `scripts/verify-replicationcontroller-lesson.sh`

## Module wrap — quick validation

**Say:**

After any DaemonSet or Job lab, this confirms nothing surprising is left Pending cluster-wide.

```bash
kubectl get deploy,sts,ds,job,cronjob,rc -A 2>/dev/null | head -n 40
kubectl get pods -A | head -n 25
```

## Troubleshooting

- **Empty `sts`/`ds` rows** → expected before you apply those lessons
- **`rc` visible from old tutorials** → see [2.4.3.8](2.4.3.8-replicationcontroller/README.md) for migration guidance
- **Many pods `Evicted` or `OOMKilled`** → revisit requests/limits ([2.4.1.7](../2.4.1-pods/2.4.1.7-pod-quality-of-service-classes/README.md))
- **Verify script fails mid-path** → delete partial objects with lesson cleanup blocks, then rerun from Deployments forward
- **Wrong namespace** → export `NS=...` if your verify scripts support it (see individual lessons)

## Next

[2.4.4 Managing Workloads](../2.4.4-managing-workloads/README.md)
