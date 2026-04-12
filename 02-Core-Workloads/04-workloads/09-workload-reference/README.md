# Workload Reference — teaching transcript

## Intro

In production you rarely manage **bare Pods**; you manage **workload API objects** that **create** Pods with consistent labels and **owner references**. Understanding the **decision table** below maps business language (“we need stable broker IDs”) to the right controller. **Deployment** targets **stateless** apps with **rolling updates**. **StatefulSet** gives **stable identity**, **ordered** rollout, and usually **per-pod PVCs**. **DaemonSet** runs a **pod per node** for agents. **Job** runs **batch** work **to completion** once (or N completions). **CronJob** schedules **Job** creation on a **cron** timer.

**Prerequisites:** [2.4.1.7 Pod Quality of Service Classes](../08-pod-quality-of-service-classes/README.md) recommended.

## Flow of this lesson

```
  Requirement in plain language
           │
           ▼
  Pick Deployment | StatefulSet | DaemonSet | Job | CronJob
           │
           ▼
  Inspect ownerReferences on live Pods
```

**Say:**

If the table says Deployment but the app writes local disk it cares about, you are holding the wrong abstraction.

## Decision table

| Controller | Use when | Avoid when |
|------------|----------|------------|
| **Deployment** | Stateless HTTP/gRPC, rolling updates, replica scale | You need **stable pod names** or **ordered** startup |
| **StatefulSet** | **Stable network ID**, ordered scale, **PVC per replica** | Embarrassingly parallel workers with no identity needs |
| **DaemonSet** | **One pod per node**: logs, metrics, CNI helpers | You only need **N** replicas unrelated to node count |
| **Job** | **Run to completion** once (or fixed **completions**) | Long-running service |
| **CronJob** | **Scheduled** batch (reports, backups) | Continuous serving traffic |

## Learning objective

- Choose **Deployment**, **StatefulSet**, **DaemonSet**, **Job**, or **CronJob** from workload requirements.
- Relate **owner references** on Pods back to the controlling resource.

## Why this matters

Wrong controller choice is expensive to unwind after data is written to local disk or clients cache pod DNS names.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/04-workloads/09-workload-reference" 2>/dev/null || cd .
```

## Step 1 — Apply reference notes

**What happens when you run this:**

ConfigMap stores narrative notes in **kube-system** when policy allows.

**Say:**

If apply fails, the **decision table** above is still the teaching payload.

**Run:**

```bash
kubectl apply -f yamls/workload-reference-notes.yaml
kubectl get configmap workload-reference-notes -n kube-system
```

**Expected:** Reference notes ConfigMap is present for mapping workload APIs to operations.

---

## Step 2 — Discover workload API resources

**What happens when you run this:**

`kubectl api-resources` filtered lists the plural names you will use in RBAC and scripting.

**Say:**

I read this list before writing **`Role.rules.resources`**.

**Run:**

```bash
kubectl api-resources | grep -E 'deployments|statefulsets|daemonsets|jobs|cronjobs' || true
```

**Expected:** Lines for deployments, replicasets (often shown), statefulsets, daemonsets, jobs, cronjobs.

---

## Step 3 — Inspect owner chain (optional, if you have a Deployment)

**What happens when you run this:**

Pods created by a **Deployment** show **ReplicaSet** as owner, and the ReplicaSet references the Deployment—teaching the chain.

**Say:**

Only run this if you completed [2.4.3.1 Deployments](../../15-workload-management/16-deployments/README.md); otherwise skip.

**Run:**

```bash
kubectl get pods -l app=deployment-demo -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.ownerReferences[0].kind}{"/"}{.metadata.ownerReferences[0].name}{"\n"}{end}' 2>/dev/null || true
```

**Expected:** Rows showing **ReplicaSet** owner if demo deployment exists.

## Video close — fast validation

```bash
kubectl api-resources | grep -E 'deployments|statefulsets|daemonsets|jobs|cronjobs' || true
```

## Troubleshooting

- **`Forbidden` to kube-system** → read ConfigMap YAML from git instead of applying
- **No ownerReferences** → bare Pod or custom operator; `describe pod` **Controlled By** field
- **CronJob missing** → wrong API group filter; try `kubectl api-resources | grep -i cron`
- **Confused Job vs Pod** → Job owns Pods; delete Job cleans template pods (policy-dependent)
- **StatefulSet pods wrong order** → check **podManagementPolicy** and readiness gates
- **grep empty** → eyes-only `kubectl api-resources` for your server version

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/workload-reference-notes.yaml` | In-cluster notes |
| `yamls/failure-troubleshooting.yaml` | API discovery workflow drills |

## Cleanup

```bash
kubectl delete configmap workload-reference-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.1.9 User Namespaces](../10-user-namespaces/README.md)
