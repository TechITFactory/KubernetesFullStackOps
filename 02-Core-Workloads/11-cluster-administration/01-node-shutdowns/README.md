# 2.11.1 Node shutdowns — teaching transcript

## Intro

**Graceful** **node** **shutdown** **integration** **lets** **the** **kubelet** **notice** **imminent** **power** **loss** **or** **maintenance** **and** **terminate** **Pods** **in** **an** **orderly** **way** **(respecting** **grace** **periods)** **instead** **of** **abrupt** **cuts**. **Platform** **operators** **still** **pair** **this** **with** **`kubectl drain`**, **PodDisruptionBudgets**, **and** **cloud** **metadata** **signals** **where** **available**. **Unplanned** **failures** **use** **different** **paths**—**this** **lesson** **focuses** **on** **planned** **and** **signaled** **shutdowns**.

**Prerequisites:** [2.11 Cluster administration](../README.md); [2.10.14 API-initiated eviction](../../10-scheduling-preemption-and-eviction/14-api-initiated-eviction/README.md).

## Flow of this lesson

```
  Shutdown signal / maintenance window
              │
              ▼
  kubelet + workload controllers coordinate Pod termination
              │
              ▼
  Node NotReady / removed from scheduling when appropriate
```

**Say:**

**I** **never** **yank** **power** **on** **a** **node** **with** **stateful** **Pods** **without** **a** **drain** **story**—**graceful** **shutdown** **is** **extra** **insurance**, **not** **a** **replacement** **for** **drain**.

## Learning objective

- Explain **why** **graceful** **shutdown** **matters** **for** **application** **data** **and** **connections**.
- Inspect **node** **readiness** **and** **recent** **events** **with** **`kubectl`**.

## Why this matters

**Hard** **stops** **corrupt** **local** **data** **and** **trip** **split-brain** **detectors** **in** **distributed** **systems**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/11-cluster-administration/01-node-shutdowns" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-11-1-node-shutdowns-notes.yaml
kubectl get cm -n kube-system 2-11-1-node-shutdowns-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-11-1-node-shutdowns-notes`** when **RBAC** **allows**.

---

## Step 2 — Node readiness and recent node events (read-only)

**What happens when you run this:**

**Surfaces** **NotReady** **nodes** **and** **recent** **events** **that** **often** **accompany** **shutdown** **tests**.

**Run:**

```bash
kubectl get nodes -o wide 2>/dev/null | head -n 20 || true
kubectl get events -A --field-selector involvedObject.kind=Node 2>/dev/null | tail -n 12 || true
```

**Expected:** **Node** **table**; **event** **lines** **(may** **be** **empty** **on** **quiet** **clusters)**.

## Video close — fast validation

```bash
kubectl describe nodes 2>/dev/null | grep -i -E 'Ready|SchedulingDisabled' | head -n 15 || true
```

## Troubleshooting

- **Drain** **stuck** → **PDBs**, **DaemonSets**, **local** **storage** **Pods**
- **No** **graceful** **shutdown** **support** → **OS**/**kubelet** **version** **gap**
- **`Forbidden` notes** → **read** **`yamls/2-11-1-node-shutdowns-notes.yaml`** **from** **git**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-11-1-node-shutdowns-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-11-1-node-shutdowns-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.11.2 Swap memory management](../02-swap-memory-management/README.md)
