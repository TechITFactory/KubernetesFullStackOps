# Node Declared Features — teaching transcript

## Intro

**Nodes** **advertise** **capabilities** **to** **the** **control** **plane** **through** **labels**, **annotations**, **`status.capacity`/`allocatable`**, **`status.nodeInfo`** **(OS**, **kubelet** **version**, **container** **runtime)**, **and** **feature-related** **fields** **that** **integrate** **with** **scheduling** **(extended** **resources**, **DRA**, **device** **plugins)**. **Accurate** **node** **identity** **prevents** **scheduling** **Pods** **onto** **OS**, **arch**, **or** **runtime** **combinations** **that** **cannot** **run** **their** **images**. **Cloud** **providers** **add** **labels** **for** **instance** **type**, **zone**, **and** **GPU** **SKUs**.

**Prerequisites:** [2.10.14 API-initiated Eviction](../14-api-initiated-eviction/README.md).

## Flow of this lesson

```
  kubelet registers node with API
              │
              ▼
  Labels + capacity/allocatable + nodeInfo published
              │
              ▼
  Scheduler and users consume features for placement rules
```

**Say:**

**I** **teach** **`kubernetes.io/arch`** **and** **`kubernetes.io/os`** **before** **custom** **GPU** **labels**—**portable** **workloads** **start** **there**.

## Learning objective

- Inspect **node** **`labels`**, **`status.nodeInfo`**, **and** **`allocatable`** **with** **`kubectl`**.
- Explain **how** **declared** **features** **feed** **nodeSelector**, **affinity**, **and** **extended** **resources**.

## Why this matters

**Wrong** **node** **labels** **after** **upgrades** **strand** **DaemonSets** **and** **break** **GPU** **scheduling** **silently** **until** **events** **pile** **up**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/10-scheduling-preemption-and-eviction/15-node-declared-features" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-10-15-node-declared-features-notes.yaml
kubectl get cm -n kube-system 2-10-15-node-declared-features-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-10-15-node-declared-features-notes`** when allowed.

---

## Step 2 — Node info and well-known labels (read-only)

**What happens when you run this:**

**First** **node** **summary** **plus** **standard** **OS**/**arch** **labels** **when** **set**.

**Run:**

```bash
N="$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)"
if [ -n "$N" ]; then kubectl get node "$N" -o jsonpath='{.status.nodeInfo}{"\n"}' 2>/dev/null; fi || true
kubectl get nodes -o custom-columns=NAME:.metadata.name,OS:.metadata.labels.kubernetes\.io/os,ARCH:.metadata.labels.kubernetes\.io/arch 2>/dev/null | head -n 15 || true
```

**Expected:** **nodeInfo** **JSON** **blob**; **OS**/**arch** **columns**.

## Video close — fast validation

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{": "}{.status.allocatable}{"\n"}{end}' 2>/dev/null | head -n 5 || true
```

## Troubleshooting

- **Missing** **GPU** **labels** → **device** **plugin** **not** **registering** **extended** **resources**
- **Stale** **node** **after** **reimage** → **delete** **and** **re-register** **(careful** **with** **PV** **local** **storage)**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-10-15-node-declared-features-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-10-15-node-declared-features-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.11 Cluster administration](../../2.11-cluster-administration/README.md)
