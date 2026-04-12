# Good practices for dynamic resource allocation as a cluster admin — teaching transcript

## Intro

**Cluster** **admins** **own** **DRA** **drivers**, **device** **plugin** **DaemonSets**, **scheduler** **configuration**, **and** **quota** **around** **shared** **accelerators**. **Good** **practices** **include** **versioning** **drivers** **with** **nodes**, **isolating** **noisy** **workloads**, **monitoring** **allocation** **failures**, **and** **documenting** **which** **teams** **may** **request** **which** **resource** **classes**. **This** **pairs** **with** **lesson** **2.10.8** **from** **the** **scheduler** **module**.

**Prerequisites:** [2.11.7 Admission webhook good practices](../07-admission-webhook-good-practices/README.md); [2.10.8 Dynamic resource allocation](../../10-scheduling-preemption-and-eviction/08-dynamic-resource-allocation/README.md).

## Flow of this lesson

```
  Hardware + driver surfaces ResourceClass / claims
              │
              ▼
  Admin policies: quota, priority, namespaces
              │
              ▼
  Observability on allocation failures and preemption
```

**Say:**

**I** **treat** **GPU** **drivers** **like** **kernel** **modules**—**pin** **versions** **to** **images** **and** **node** **pools**.

## Learning objective

- Discover **DRA-related** **API** **resources** **when** **the** **cluster** **exposes** **them**.
- List **admin** **concerns** **distinct** **from** **application** **`resources.limits`** **strings**.

## Why this matters

**Shared** **clusters** **without** **governance** **on** **accelerators** **become** **ticket** **queues** **and** **idle** **hardware** **at** **the** **same** **time**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/11-cluster-administration/08-good-practices-for-dynamic-resource-allocation-as-a-cluster-admin" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-11-8-good-practices-for-dynamic-resource-allocation-as-a-cluster-admin-notes.yaml
kubectl get cm -n kube-system 2-11-8-good-practices-for-dynamic-resource-allocation-as-a-cluster-admin-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-11-8-good-practices-for-dynamic-resource-allocation-as-a-cluster-admin-notes`** when allowed.

---

## Step 2 — DRA-related API discovery (read-only)

**What happens when you run this:**

**Greps** **`api-resources`** **for** **claim**/**class** **style** **names** **when** **installed**.

**Run:**

```bash
kubectl api-resources 2>/dev/null | grep -iE 'resourceclaim|resourceclass|device' | head -n 25 || true
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{": "}{range $k,$v := .status.allocatable}{ $k }={ $v } {end}{"\n"}{end}' 2>/dev/null | grep -iE 'gpu|nvidia|amd' | head -n 10 || true
```

**Expected:** **Resource** **rows** **or** **empty**; **GPU-style** **allocatable** **keys** **if** **present**.

## Video close — fast validation

```bash
kubectl get pods -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"/"}{.metadata.name}{": "}{.spec.containers[0].resources.limits}{"\n"}{end}' 2>/dev/null | grep -i gpu | head -n 8 || true
```

## Troubleshooting

- **No** **DRA** **APIs** → **feature** **not** **enabled** **or** **older** **release**
- **Driver** **pod** **CrashLoop** → **node** **kernel** **vs** **container** **image** **skew**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-11-8-good-practices-for-dynamic-resource-allocation-as-a-cluster-admin-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-11-8-good-practices-for-dynamic-resource-allocation-as-a-cluster-admin-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.11.9 Logging architecture](../09-logging-architecture/README.md)
