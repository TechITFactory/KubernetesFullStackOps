# Workloads — teaching transcript

## Intro

Workloads are how you tell Kubernetes **what should run** and **how much of it**. The **Pod** is the smallest unit the scheduler places and the kubelet runs; it is where containers actually execute. You rarely stop at a bare Pod in production: **controllers** (ReplicaSet, Deployment, StatefulSet, DaemonSet, Job, CronJob) are the **management layer**—they watch the API, compare desired state to reality, and create or replace Pods. **Autoscaling** (for example **Horizontal Pod Autoscaler**) sits on top as the **demand layer**, adjusting replica counts when metrics say traffic or CPU needs more or fewer Pods. This module walks from Pod mechanics through those controllers to rollout operations and autoscaling so you can read cluster state and YAML with the same mental model as a platform engineer.

**Prerequisites:** [Part 2 entry check](../README.md#prerequisites-met-read-this-before-21) — `kubectl cluster-info` and `/readyz` must work.

**Tested-on note:** Demos use `busybox` and `nginx` public images; compatible with any recent supported Kubernetes (see [`KUBERNETES_VERSION_MATRIX.md`](../../KUBERNETES_VERSION_MATRIX.md)).

## Flow of this lesson

```
  Pod (runs on node)
    │
    ▼
  ReplicaSet (keeps N pods matching labels)
    │
    ▼
  Deployment (rolling updates, history, owns ReplicaSet)
    │
    ▼
  HPA (scales Deployment replicas from metrics)
```

**Say:**

The API stores each object; controllers reconcile downward. HPA only changes **replicas** on a scalable target—it does not replace the Pod template. That chain is why a bad image shows up as a new ReplicaSet under the same Deployment, and why CPU scale events show up on the HPA before you see new Pods.

## Learning objective

- Explain how a **Pod** relates to **ReplicaSet**, **Deployment**, and **HPA** in the reconciliation chain.
- Use module verification scripts to confirm **core path** labs completed successfully.

## Why this matters

Interview answers and incident triage both assume you know **which layer** owns a symptom: Pod crash versus ReplicaSet churn versus Deployment rollout versus HPA thrash.

## Children

- [2.4.1 Pods](01-pods/README.md)
- [2.4.2 Workload API](13-workload-api/README.md)
- [2.4.3 Workload Management](15-workload-management/README.md)
- [2.4.4 Managing Workloads](24-managing-workloads/README.md)
- [2.4.5 Autoscaling Workloads](25-autoscaling-workloads/README.md)

## Module verification

From this directory:

```bash
bash scripts/verify-2-4-workloads-module.sh
```

After you apply the YAMLs / run the scripts for the **core path** (through **2.4.4**), run:

```bash
bash scripts/verify-2-4-workloads-module.sh --labs
```

(`--labs` includes **Job TTL wait** and expects **`manage-workloads-demo.sh`** to have been run so the Deployment is at **3** replicas and **nginx:1.27**.)

## Module wrap — quick validation

**What happens when you run this:** Read-only inventory of workload controllers and pods; useful after any rollout or failure drill.

**Say:**

I use this as a thirty-second sanity pass before filming the next subsection or after a verify script fails halfway.

```bash
kubectl get deploy,sts,ds,job,cronjob,hpa -A 2>/dev/null | head -n 40
kubectl get pods -A | head -n 30
kubectl get events -A --sort-by=.lastTimestamp | tail -n 25
```

## Troubleshooting

- **`verify-2-4-workloads-module.sh` fails on labs** → run the core path lessons in order; ensure **manage-workloads-demo** finished with **3** replicas and **nginx:1.27** as the script expects
- **No HPA in cluster output** → HPA lesson is optional until metrics-server and a scalable target exist
- **Empty `cronjob`/`job` rows** → normal on fresh clusters until you apply CronJob/Job demos
- **`kubectl get` RBAC denied** → use a namespace-scoped user or widen read RBAC for teaching
- **Script not executable** → `chmod +x scripts/verify-2-4-workloads-module.sh`

## Next

[2.5 Services, Load Balancing, and Networking](../05-services-load-balancing-and-networking/README.md) — connect workloads to stable network identities.
