# 2.4.3 Workload Management â€” teaching transcript

## Intro

Controllers turn **desired state** in the API into **running Pods**. A **Deployment** is the usual choice for **stateless** apps: it performs **rolling updates**, keeps **ReplicaSets** under the hood, and preserves **revision history** for rollback. The **ReplicaSet** is the mechanism that matches a **label selector** to a replica count; you normally let the Deployment own it. A **StatefulSet** adds **ordered** creation, **stable network identity**, and often **per-pod storage** via **volumeClaimTemplates**. A **DaemonSet** runs **one pod per eligible node**â€”think log agents, node exporters, or CNI components. **Jobs** run pods **to completion**; **CronJobs** create Jobs on a **schedule**. Together these are the workload management toolkit you will see in every cluster.

**Prerequisites:** [2.4.1.1 Pod Lifecycle](../01-pods/02-pod-lifecycle/README.md) recommended so Pod phases and conditions are fresh.

## Flow of this lesson

```
  Need stable identity + ordered pods + PVCs each?
        â”‚ yes                          â”‚ no
        â–¼                                â–¼
   StatefulSet                    One pod per node?
                                      â”‚ yes â†’ DaemonSet
                                      â”‚ no
                                      â–¼
                              Batch / schedule?
                                 â”‚ one-shot â†’ Job
                                 â”‚ recurring â†’ CronJob
                                 â”‚ long-running stateless â†’ Deployment
```

**Say:**

This is a decision flow for **which controller**, not a mandate to skip reading Pod specs. StatefulSet without headless Service and storage is incomplete; DaemonSet without **tolerations** often misses control-plane nodes.

## Learning objective

- Match **Deployment**, **ReplicaSet**, **StatefulSet**, **DaemonSet**, **Job**, and **CronJob** to their primary use cases.
- Follow the numbered children in order for the **core path** with verify scripts.

## Why this matters

Choosing the wrong controller shows up months later as painful migrationsâ€”especially mistaking StatefulSet ordering for â€œjust another Deployment.â€

## Children (suggested order)

1. [2.4.3.1 Deployments](16-deployments/README.md) â€” **default stateless app** (transcript + verify).
2. [2.4.3.2 ReplicaSet](17-replicaset/README.md) â€” what Deployments own under the hood (transcript + verify).
3. [2.4.3.3 StatefulSets](18-statefulsets/README.md) â€” transcript + `../18-statefulsets/scripts/verify-statefulset-lesson.sh`
4. [2.4.3.4 DaemonSet](19-daemonset/README.md) â€” transcript + `../19-daemonset/scripts/verify-daemonset-lesson.sh`
5. [2.4.3.5 Jobs](20-jobs/README.md) â€” transcript + `../20-jobs/scripts/verify-jobs-lesson.sh`
6. [2.4.3.6 Automatic Cleanup for Finished Jobs](21-automatic-cleanup-for-finished-jobs/README.md) â€” transcript + `../21-automatic-cleanup-for-finished-jobs/scripts/verify-job-ttl-lesson.sh` (waits for TTL deletion)
7. [2.4.3.7 CronJob](22-cronjob/README.md) â€” transcript + `../22-cronjob/scripts/verify-cronjob-lesson.sh` (`kubectl create job --from=cronjob/...`)
8. [2.4.3.8 ReplicationController](23-replicationcontroller/README.md) â€” transcript + `../23-replicationcontroller/scripts/verify-replicationcontroller-lesson.sh`

## Module wrap â€” quick validation

**Say:**

After any DaemonSet or Job lab, this confirms nothing surprising is left Pending cluster-wide.

```bash
kubectl get deploy,sts,ds,job,cronjob,rc -A 2>/dev/null | head -n 40
kubectl get pods -A | head -n 25
```

## Troubleshooting

- **Empty `sts`/`ds` rows** â†’ expected before you apply those lessons
- **`rc` visible from old tutorials** â†’ see [2.4.3.8](23-replicationcontroller/README.md) for migration guidance
- **Many pods `Evicted` or `OOMKilled`** â†’ revisit requests/limits ([2.4.1.7](../01-pods/08-pod-quality-of-service-classes/README.md))
- **Verify script fails mid-path** â†’ delete partial objects with lesson cleanup blocks, then rerun from Deployments forward
- **Wrong namespace** â†’ export `NS=...` if your verify scripts support it (see individual lessons)

## Next

[2.4.4 Managing Workloads](../24-managing-workloads/README.md)
