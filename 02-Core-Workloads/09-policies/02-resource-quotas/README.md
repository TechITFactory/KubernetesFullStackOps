# 2.9.2 Resource Quotas — teaching transcript

## Intro

**ResourceQuota** caps **aggregate** **usage** in a **namespace**: **sum** of **CPU**/**memory** **requests** and **limits** across **Pods**, **counts** of **objects** (**Pods**, **Services**, **PVCs**, **Secrets**, …), and sometimes **storage** **per** **StorageClass**. When a **create** would **exceed** **quota**, the **API** **returns** **403** **Forbidden**. **Scopes** and **scopeSelector** narrow **which** **Pods** **count** (**BestEffort**, **Terminating**, …). **Quota** **tracks** **requests** **for** **schedulable** **resources** **even** **when** **LimitRange** **filled** **in** **missing** **requests**.

**Prerequisites:** [2.9.1 Limit Ranges](../01-limit-ranges/README.md).

## Flow of this lesson

```
  ResourceQuota object + hard: limits
              │
              ▼
  apiserver quota controller updates Status
              │
              ▼
  Admission rejects over-quota creates
```

**Say:**

I **show** **`kubectl describe resourcequota`** **used** **vs** **hard** **while** **someone** **tries** **to** **scale** **a** **Deployment** **past** **the** **cap**.

## Learning objective

- Read **ResourceQuota** **`.status.hard`** vs **`.status.used`** with **`kubectl describe`**.
- Name **common** **quota** **dimensions** (**compute**, **object** **count**, **storage**).

## Why this matters

**Multi-tenant** **platforms** **without** **object** **count** **quotas** **learn** **about** **etcd** **size** **from** **outages**, **not** **dashboards**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/09-policies/02-resource-quotas" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** in **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-9-2-resource-quotas-notes.yaml
kubectl get cm -n kube-system 2-9-2-resource-quotas-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-9-2-resource-quotas-notes`** when allowed.

---

## Step 2 — Cluster-wide quotas and explain scopes (read-only)

**What happens when you run this:**

Reuses the **shared** **inspect** **pattern** with **LimitRange** **in** **one** **view**; **`explain`** **covers** **scopes**.

**Run:**

```bash
bash scripts/inspect-2-9-2-resource-quotas.sh 2>/dev/null || true
kubectl explain resourcequota.spec.scopeSelector 2>/dev/null | head -n 25 || true
```

**Expected:** **`resourcequota,limitrange`** **listing**; **scope** **docs** **or** **empty** **on** **very** **old** **clients**.

## Video close — fast validation

```bash
kubectl get resourcequota -A 2>/dev/null | head -n 20 || true
```

## Troubleshooting

- **Quota** **not** **updating** → **controller** **lag**; **retry** **describe** **after** **seconds**
- **`limits.cpu` vs `requests.cpu`** → **teach** **which** **your** **policy** **actually** **enforces**
- **Terminating** **Pods** **still** **count** → **explain** **until** **fully** **removed**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-9-2-resource-quotas-notes.yaml` | Notes ConfigMap |
| `scripts/inspect-2-9-2-resource-quotas.sh` | Lists **ResourceQuota** and **LimitRange** cluster-wide |

## Cleanup

```bash
kubectl delete configmap 2-9-2-resource-quotas-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.9.3 Process ID Limits and Reservations](../03-process-id-limits-and-reservations/README.md)
