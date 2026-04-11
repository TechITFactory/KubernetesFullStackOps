# 2.9.1 Limit Ranges — teaching transcript

## Intro

A **LimitRange** is a **namespace-scoped** **policy** object that **defaults** or **constrains** **CPU**, **memory**, **storage** **requests**/**limits**, **PVC** **sizes**, and (where supported) **ratio** rules so **individual** **Pods** cannot **omit** **requests** or **exceed** **sane** **ceilings**. The **admission** **plugin** **mutates** or **rejects** **creates** **at** **Pod**/**container**/**PVC** **scope**. It complements **ResourceQuota** (next lesson), which caps **totals**—**LimitRange** shapes **each** **object**.

**Prerequisites:** [2.7.4 Resource management for pods and containers](../../07-configuration/04-resource-management-for-pods-and-containers/README.md); [2.9 Policies](../README.md).

## Flow of this lesson

```
  LimitRange object in namespace
              │
              ▼
  Admission: default / defaultRequest / max / min per item type
              │
              ▼
  Pod or PVC created (or rejected)
```

**Say:**

If **developers** **forget** **requests**, **LimitRange** **defaultRequest** **fixes** **scheduling** **without** **every** **chart** **duplicating** **the** **same** **numbers**.

## Learning objective

- Describe **LimitRange** **types** (**Container**, **Pod**, **PersistentVolumeClaim**) at a high level.
- List **LimitRange** **objects** and open **`kubectl explain`** for the **API** **shape**.

## Why this matters

**Missing** **requests** **causes** **BestEffort** **QoS** **and** **noisy** **neighbors**; **LimitRange** **is** **the** **cheap** **namespace** **default**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/09-policies/01-limit-ranges" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Stores **lesson** **prompt** **text** in **kube-system** (if permitted).

**Run:**

```bash
kubectl apply -f yamls/2-9-1-limit-ranges-notes.yaml
kubectl get cm -n kube-system 2-9-1-limit-ranges-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-9-1-limit-ranges-notes`** when **RBAC** **allows**.

---

## Step 2 — Inspect LimitRanges and explain the spec (read-only)

**What happens when you run this:**

Shows **whether** **any** **namespaces** **define** **defaults**; **`explain`** **anchors** **the** **field** **names** **you** **teach**.

**Say:**

I **walk** **one** **live** **`kubectl describe limitrange`** **line** **by** **line** **when** **a** **sample** **exists**.

**Run:**

```bash
bash scripts/inspect-2-9-1-limit-ranges.sh 2>/dev/null || kubectl get limitrange -A 2>/dev/null || true
kubectl explain limitrange.spec.limits 2>/dev/null | head -n 35 || true
```

**Expected:** **Table** **of** **quota/limitrange** **(script)** **or** **at** **least** **limitrange** **list**; **explain** **output** **for** **limits** **array**.

## Video close — fast validation

```bash
kubectl get limitrange -A -o wide 2>/dev/null | head -n 15 || true
```

## Troubleshooting

- **`Default** **and** **defaultRequest** **conflict** → **fix** **policy** **so** **defaults** **stay** **≤** **max**
- **PVC** **min** **>** **storage** **class** **default** → **admission** **errors** **on** **claim** **create**
- **Script** **`set -e`** **exits** **on** **empty** **cluster** **edge** **cases** → **run** **`kubectl get limitrange -A`** **manually**
- **`Forbidden` notes** → **read** **`yamls/2-9-1-limit-ranges-notes.yaml`** **from** **git**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-9-1-limit-ranges-notes.yaml` | Notes ConfigMap |
| `scripts/inspect-2-9-1-limit-ranges.sh` | Lists **ResourceQuota** and **LimitRange** cluster-wide |

## Cleanup

```bash
kubectl delete configmap 2-9-1-limit-ranges-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.9.2 Resource Quotas](../02-resource-quotas/README.md)
