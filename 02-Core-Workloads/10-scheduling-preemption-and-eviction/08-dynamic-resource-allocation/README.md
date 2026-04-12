# Dynamic Resource Allocation — teaching transcript

## Intro

**Dynamic** **Resource** **Allocation** **(DRA)** **extends** **Kubernetes** **beyond** **static** **extended** **resources** **like** **`nvidia.com/gpu`** **by** **modeling** **devices** **with** **`ResourceClaim`** **templates**, **drivers**, **and** **structured** **parameters**. **Pods** **reference** **claims** **so** **the** **scheduler** **and** **kubelet** **coordinate** **allocation** **with** **device** **plugins** **and** **vendor** **controllers**. **Clusters** **without** **DRA** **enabled** **may** **lack** **these** **APIs**—**teach** **the** **pattern** **and** **gracefully** **handle** **`NotFound`** **on** **`kubectl explain`**.

**Prerequisites:** [2.10.7 Scheduling Framework](../07-scheduling-framework/README.md).

## Flow of this lesson

```
  Admin defines ResourceClass / driver surfaces devices
              │
              ▼
  Workload creates ResourceClaim (or uses template)
              │
              ▼
  Pod resourceClaims binds claim → scheduler + kubelet allocate
```

**Say:**

**DRA** **is** **the** **successor** **story** **to** **counting** **GPUs** **as** **opaque** **integers**—**structured** **allocation** **reduces** **fragmentation** **when** **done** **right**.

## Learning objective

- Locate **DRA-related** **API** **objects** **with** **`kubectl api-resources`** **when** **installed**.
- Explain **why** **DRA** **touches** **both** **scheduling** **and** **kubelet** **admission**.

## Why this matters

**AI** **workloads** **push** **clusters** **past** **simple** **`limits`** **strings**—**DRA** **is** **where** **Kubernetes** **meets** **hardware** **topology** **and** **sharing** **models**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/10-scheduling-preemption-and-eviction/08-dynamic-resource-allocation" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-10-8-dynamic-resource-allocation-notes.yaml
kubectl get cm -n kube-system 2-10-8-dynamic-resource-allocation-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-10-8-dynamic-resource-allocation-notes`** when allowed.

---

## Step 2 — Discover DRA APIs and Pod claim fields (read-only)

**What happens when you run this:**

**Lists** **resource** **group** **names** **if** **present**; **`explain`** **may** **fail** **on** **older** **clusters**.

**Run:**

```bash
kubectl api-resources 2>/dev/null | grep -i resourceclaim | head -n 15 || true
kubectl explain pod.spec.resourceClaims 2>/dev/null | head -n 30 || true
```

**Expected:** **resourceclaim** **rows** **or** **empty**; **explain** **output** **or** **error**.

## Video close — fast validation

```bash
kubectl get resourceclaim -A 2>/dev/null | head -n 10 || true
```

## Troubleshooting

- **CRDs** **missing** → **feature** **gate**, **cluster** **version**, **or** **cloud** **support** **gap**
- **Claims** **stuck** **Pending** → **driver** **DaemonSet**, **capacity**, **scheduler** **plugins**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-10-8-dynamic-resource-allocation-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-10-8-dynamic-resource-allocation-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.10.9 Gang Scheduling](../09-gang-scheduling/README.md)
