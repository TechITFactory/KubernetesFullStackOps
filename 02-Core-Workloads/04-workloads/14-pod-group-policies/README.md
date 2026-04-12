# Pod Group Policies — teaching transcript

## Intro

This lesson focuses on **namespace-scoped policy objects** that shape how Pods are **sized** and **counted**. A **LimitRange** sets **defaults**, **minimums**, and **maximums** for **CPU/memory** (and other resources) **per Pod or per container** in a namespace—when a Pod omits requests/limits, LimitRange can fill them in at admission time. A **ResourceQuota** caps **namespace totals**: aggregate **CPU/memory requests or limits**, **object counts**, and sometimes **storage**. The **interaction** matters: if LimitRange **defaults** would make a new Pod exceed **ResourceQuota**, admission **rejects** the Pod even though each field looked legal in isolation.

**Prerequisites:** [2.4.2 Workload API](../README.md); [2.4.1.7 QoS](../../01-pods/08-pod-quality-of-service-classes/README.md) helpful.

## Flow of this lesson

```
  Namespace
    ├── LimitRange  → defaults / min / max per pod/container
    └── ResourceQuota → total requests/limits/objects
              │
              ▼
  Admission: default + quota must both pass
```

**Say:**

Platform teams pair **LimitRange** (“no BestEffort by accident”) with **Quota** (“this team gets 20 cores max”).

## Learning objective

- Explain **LimitRange** versus **ResourceQuota** responsibilities.
- Describe how **defaulted limits** interact with **quota** enforcement.
- Discover existing policies with **`kubectl get`**.

## Why this matters

“Works on my laptop” Pods fail first integration test when the shared dev namespace enforces quota.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/04-workloads/13-workload-api/14-pod-group-policies" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

The bundled ConfigMap carries high-level **group scheduling** notes; pair it verbally with LimitRange/Quota in this transcript.

**Say:**

The YAML body still mentions affinity-style grouping—use your narration to pivot to **quota** mechanics.

**Run:**

```bash
kubectl apply -f yamls/pod-group-policies-notes.yaml
kubectl get configmap pod-group-policies-notes -n kube-system
```

**Expected:** Notes ConfigMap is available in `kube-system` when RBAC allows.

---

## Step 2 — Discover LimitRange and ResourceQuota in the cluster

**What happens when you run this:**

Lists real policies—often empty on toy clusters, which is itself a teaching moment.

**Say:**

Empty output means “no automatic defaults”—Pods may remain **BestEffort** until someone adds LimitRange.

**Run:**

```bash
kubectl get limitrange -A 2>/dev/null || true
kubectl get resourcequota -A 2>/dev/null || true
```

**Expected:** Whatever your cluster defines; toy clusters may show no resources.

---

## Step 3 — Sample pod scheduling inventory

**What happens when you run this:**

Grounds the policy discussion in running workloads.

**Say:**

I correlate **namespace** names with **quota** objects before debugging a **Forbidden** create.

**Run:**

```bash
kubectl get pods -A | head -n 15
kubectl api-resources | grep -i scheduling || true
```

**Expected:** Short pod list; optional scheduling-related API kinds.

## Video close — fast validation

```bash
kubectl get limitrange -A 2>/dev/null || true
kubectl get resourcequota -A 2>/dev/null || true
```

## Troubleshooting

- **`exceeded quota` on create** → check **ResourceQuota** `used` vs `hard`; remember LimitRange **defaults** count toward quota
- **Pod rejected with no obvious quota line** → inspect **LimitRange** default **memory** spike
- **`Forbidden` listing kube-system** → run without `-n kube-system` or widen RBAC
- **LimitRange not applied** → wrong **namespace**; LimitRange is namespaced
- **Burstable surprise** → LimitRange set **defaultRequest** without matching **default limit**—map to [QoS lesson](../../01-pods/08-pod-quality-of-service-classes/README.md)
- **Storage quota** → separate from CPU; check `requests.storage` in **ResourceQuota**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/pod-group-policies-notes.yaml` | In-cluster notes ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Feature gate and policy mismatches |

## Cleanup

```bash
kubectl delete configmap pod-group-policies-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.3 Workload Management](../../15-workload-management/README.md)
