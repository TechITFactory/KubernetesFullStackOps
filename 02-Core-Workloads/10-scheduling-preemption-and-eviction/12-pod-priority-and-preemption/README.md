# 2.10.12 Pod Priority and Preemption — teaching transcript

## Intro

**PriorityClass** **objects** **assign** **integer** **priorities** **to** **Pods** **via** **`spec.priorityClassName`**. **When** **a** **high-priority** **Pod** **cannot** **schedule**, **the** **scheduler** **may** **preempt** **(evict)** **lower-priority** **Pods** **to** **free** **resources**. **`globalDefault`** **classes** **apply** **to** **Pods** **without** **an** **explicit** **class**. **System** **classes** **protect** **cluster** **components**—**do** **not** **reuse** **their** **values** **for** **app** **workloads** **without** **understanding** **the** **blast** **radius**.

**Prerequisites:** [2.10.11 Resource Bin Packing](../11-resource-bin-packing/README.md).

## Flow of this lesson

```
  PriorityClass defines priority value
              │
              ▼
  Pending high-priority Pod triggers preemption path
              │
              ▼
  Lower-priority Pods receive preemption signals / deletion
```

**Say:**

**Preemption** **is** **not** **graceful** **by** **default** **for** **the** **victim**—**pair** **with** **PDBs** **(next** **module** **touches** **disruption** **more** **broadly)** **and** **application** **SIGTERM** **handling**.

## Learning objective

- List **PriorityClass** **objects** **and** **explain** **`pod.spec.priority`** **and** **`priorityClassName`** **fields**.
- Describe **preemption** **as** **a** **scheduler** **action** **distinct** **from** **kubelet** **pressure** **eviction**.

## Why this matters

**Wild-west** **PriorityClass** **values** **let** **one** **team** **starve** **another** **without** **Quota** **catching** **it** **(priority** **is** **orthogonal** **to** **namespace** **quotas)**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/10-scheduling-preemption-and-eviction/12-pod-priority-and-preemption" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-10-12-pod-priority-and-preemption-notes.yaml
kubectl get cm -n kube-system 2-10-12-pod-priority-and-preemption-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-10-12-pod-priority-and-preemption-notes`** when allowed.

---

## Step 2 — Inventory PriorityClasses and explain Pod fields (read-only)

**What happens when you run this:**

**Shows** **global** **defaults** **and** **system** **classes**; **`explain`** **anchors** **the** **spec**.

**Run:**

```bash
kubectl get priorityclass 2>/dev/null | head -n 20 || true
kubectl explain pod.spec.priorityClassName 2>/dev/null | head -n 15 || true
kubectl explain pod.spec.priority 2>/dev/null | head -n 12 || true
```

**Expected:** **PriorityClass** **table**; **explain** **snippets**.

## Video close — fast validation

```bash
kubectl explain priorityclass 2>/dev/null | head -n 25 || true
```

## Troubleshooting

- **Preemption** **loops** → **equal** **priority** **rules** **and** **PDB** **constraints**
- **No** **PriorityClass** **CRD** **visible** → **RBAC** **or** **very** **old** **cluster**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-10-12-pod-priority-and-preemption-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-10-12-pod-priority-and-preemption-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.10.13 Node-pressure Eviction](../13-node-pressure-eviction/README.md)
