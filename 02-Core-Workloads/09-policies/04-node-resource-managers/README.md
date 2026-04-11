# 2.9.4 Node Resource Managers — teaching transcript

## Intro

On each **node**, the **kubelet** runs **managers** that **align** **local** **resources** **with** **Pod** **specs**: **CPU** **Manager** (**static** **policy** **pins** **exclusive** **cores** **for** **Guaranteed** **Pods** **with** **integer** **CPU** **requests**); **Device** **Manager** **coordinates** **device** **plugins** (**GPU**, **FPGA**, **custom**); **Topology** **Manager** **merges** **NUMA** **hints** **so** **memory**, **CPU**, and **devices** **land** **on** **coherent** **sockets** **when** **possible**. These are **not** **objects** **you** **`kubectl apply`** **in** **this** **lesson**—they **are** **kubelet** **configuration** **plus** **runtime** **behavior** **visible** **indirectly** **in** **Pod** **status** **and** **node** **conditions**.

**Prerequisites:** [2.9.3 Process ID Limits and Reservations](../03-process-id-limits-and-reservations/README.md); [2.7.4 Resource management for pods and containers](../../07-configuration/04-resource-management-for-pods-and-containers/README.md).

## Flow of this lesson

```
  Pod with integer CPU / device requests
              │
              ▼
  Scheduler picks node (allocatable, extended resources)
              │
              ▼
  kubelet: CPU / Device / Topology managers place workloads on CPUs & NUMA
```

**Say:**

**Topology** **Manager** **is** **the** **reason** **your** **GPU** **job** **gets** **faster** **when** **CPU** **and** **GPU** **sit** **on** **the** **same** **NUMA** **node**—**not** **magic**, **alignment**.

## Learning objective

- Name **CPU** **Manager**, **Device** **Manager**, and **Topology** **Manager** **and** **what** **each** **optimizes**.
- Inspect **node** **allocatable** **and** **capacity** **for** **extended** **resources** **with** **`kubectl`**.

## Why this matters

**Wrong** **kubelet** **CPU** **policy** **or** **missing** **topology** **awareness** **wastes** **hardware** **you** **paid** **for** **and** **shows** **up** **as** **mysterious** **latency** **jitter**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/09-policies/04-node-resource-managers" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Node **manager** **teaching** **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-9-4-node-resource-managers-notes.yaml
kubectl get cm -n kube-system 2-9-4-node-resource-managers-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-9-4-node-resource-managers-notes`** when allowed.

---

## Step 2 — Node capacity, allocatable, and extended resources (read-only)

**What happens when you run this:**

**`describe node`** **shows** **Allocatable** **CPU**, **memory**, **pods**, and **vendor** **extended** **resources** **advertised** **by** **device** **plugins**.

**Say:**

I **filter** **`describe`** **output** **for** **`nvidia.com/gpu`** **or** **your** **org’s** **resource** **names** **during** **recording**.

**Run:**

```bash
kubectl get nodes -o custom-columns=NAME:.metadata.name,CPU:.status.allocatable.cpu,MEM:.status.allocatable.memory,PODS:.status.allocatable.pods 2>/dev/null | head -n 15 || true
N="$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)"
if [ -n "$N" ]; then kubectl describe node "$N" 2>/dev/null | sed -n '/Allocatable:/,/System Info:/p' | head -n 40; fi || true
```

**Expected:** **Per-node** **allocatable** **table** **and** **a** **truncated** **Allocatable** **section** **including** **non-standard** **keys** **when** **present**.

## Video close — fast validation

```bash
kubectl explain pod.spec.containers.resources.limits 2>/dev/null | head -n 15 || true
```

## Troubleshooting

- **No** **extended** **resources** **visible** → **device** **plugin** **DaemonSet** **not** **running** **or** **different** **node** **pool**
- **CPU** **static** **policy** **surprises** → **only** **Guaranteed** **Pods** **with** **whole** **CPU** **requests** **get** **exclusive** **cores** **(typical** **rules**)
- **`sed` portability** → on Windows, run in Git Bash or WSL, or use `kubectl describe` without `sed`
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-9-4-node-resource-managers-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-9-4-node-resource-managers-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.11 Cluster administration](../../2.11-cluster-administration/README.md)
