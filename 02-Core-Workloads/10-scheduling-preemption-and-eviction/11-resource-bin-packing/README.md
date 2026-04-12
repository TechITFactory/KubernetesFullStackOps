# Resource Bin Packing — teaching transcript

## Intro

**Bin** **packing** **(dense** **placement)** **vs** **spreading** **is** **a** **scoring** **trade-off**: **packing** **raises** **utilization** **and** **can** **reduce** **cost** **but** **increases** **blast** **radius** **on** **a** **node** **failure**; **spreading** **improves** **resilience** **but** **fragments** **free** **CPU**/**memory** **below** **schedulable** **chunks**. **Scheduler** **plugins** **like** **`NodeResourcesFit`** **and** **related** **scoring** **extensions** **encode** **these** **preferences**. **Cluster** **autoscaler** **interacts** **with** **packing** **because** **under-packed** **nodes** **may** **stay** **online** **longer** **than** **finance** **expects**.

**Prerequisites:** [2.10.10 Scheduler Performance Tuning](../10-scheduler-performance-tuning/README.md).

## Flow of this lesson

```
  Filter: which nodes fit requests
              │
              ▼
  Score: prefer tighter packs or balanced spreads (policy)
              │
              ▼
  Bind: chosen node reflects the scoring weights
```

**Say:**

**FinOps** **loves** **packing**; **SRE** **loves** **headroom**—**your** **scheduler** **weights** **encode** **that** **organizational** **tension**.

## Learning objective

- Contrast **bin** **packing** **with** **topology** **spread** **and** **anti-affinity** **goals**.
- Read **node** **`capacity`** **vs** **`allocatable`** **to** **reason** **about** **schedulable** **chunks**.

## Why this matters

**Misaligned** **packing** **and** **HPA** **targets** **cause** **either** **waste** **or** **constant** **thrash** **during** **scale** **events**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/10-scheduling-preemption-and-eviction/11-resource-bin-packing" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-10-11-resource-bin-packing-notes.yaml
kubectl get cm -n kube-system 2-10-11-resource-bin-packing-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-10-11-resource-bin-packing-notes`** when allowed.

---

## Step 2 — Capacity vs allocatable on nodes (read-only)

**What happens when you run this:**

**Shows** **kube-reserved** **and** **system** **reservations** **as** **the** **gap** **between** **hardware** **and** **schedulable** **resources**.

**Run:**

```bash
N="$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)"
if [ -n "$N" ]; then kubectl get node "$N" -o jsonpath='{.status.capacity}{"\n"}{.status.allocatable}{"\n"}' 2>/dev/null; fi || true
```

**Expected:** **Two** **JSON** **maps** **(capacity**, **allocatable)** **or** **empty**.

## Video close — fast validation

```bash
kubectl top nodes 2>/dev/null | head -n 10 || true
```

## Troubleshooting

- **`metrics-server` missing** → **`top`** **fails**—**skip** **or** **install** **for** **demos**
- **Allocatable** **<<** **capacity** → **normal**—**explain** **reservations**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-10-11-resource-bin-packing-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-10-11-resource-bin-packing-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.10.12 Pod Priority and Preemption](../12-pod-priority-and-preemption/README.md)
