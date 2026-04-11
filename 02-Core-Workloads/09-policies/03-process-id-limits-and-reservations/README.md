# 2.9.3 Process ID Limits and Reservations — teaching transcript

## Intro

**Linux** **PIDs** are a **finite** **per-cgroup** **resource**. **Kubernetes** **limits** **PIDs** **per** **Pod** **via** **kubelet** **configuration** (**podPidsLimit** and related settings) and **container** **runtime** **cgroup** **integration** so a **fork** **bomb** **cannot** **take** **down** **a** **node**. **Reservations** (kubelet **system** **reserved** **PIDs** / **node** **allocatable** **assumptions**) keep **room** **for** **kubelet**, **runtime**, and **system** **daemons**. This lesson is **partly** **node** **config**: **you** **may** **not** **see** **flags** **on** **managed** **control** **planes**—**narrate** **the** **contract** **and** **symptoms** (**eviction**, **StartError**) **when** **PIDs** **exhaust**.

**Prerequisites:** [2.9.2 Resource Quotas](../02-resource-quotas/README.md); [2.7.4 Resource management for pods and containers](../../07-configuration/04-resource-management-for-pods-and-containers/README.md).

## Flow of this lesson

```
  kubelet + runtime → cgroup pids.max (per pod / per container)
              │
              ▼
  Scheduler still uses CPU/memory; PID pressure surfaces at start/runtime
              │
              ▼
  Eviction or throttling when limits hit
```

**Say:**

**OOM** **gets** **the** **glory**; **PID** **exhaustion** **looks** **like** **random** **cannot** **allocate** **memory** **errors** **in** **app** **logs**—**I** **check** **`dmesg`** **and** **cgroup** **pids** **on** **the** **node**.

## Learning objective

- Explain **why** **PID** **limits** **are** **orthogonal** **to** **CPU**/**memory** **requests**.
- Use **`kubectl explain`** on **container** **resources** **and** **relate** **to** **kubelet** **PID** **policy** **in** **docs**.

## Why this matters

**Java** **apps** **and** **runaway** **thread** **pools** **can** **blow** **PID** **budgets** **before** **memory** **limits** **trigger**—**without** **limits**, **one** **namespace** **can** **deny** **fork** **to** **others** **on** **the** **same** **node**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/09-policies/03-process-id-limits-and-reservations" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

PID **policy** **teaching** **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-9-3-process-id-limits-and-reservations-notes.yaml
kubectl get cm -n kube-system 2-9-3-process-id-limits-and-reservations-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-9-3-process-id-limits-and-reservations-notes`** when allowed.

---

## Step 2 — Relate Pods to resource fields (read-only)

**What happens when you run this:**

**CPU**/**memory** **fields** **are** **visible** **in** **API** **docs**; **PID** **enforcement** **is** **often** **kubelet**/**runtime**—**this** **step** **grounds** **the** **comparison**.

**Say:**

On **self-managed** **clusters**, I **grep** **kubelet** **config** **for** **`podPidsLimit`** **on** **a** **worker** **SSH** **session**—**off** **camera** **if** **needed**.

**Run:**

```bash
kubectl explain pod.spec.containers.resources.limits 2>/dev/null | head -n 30 || true
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{": allocatable="}{.status.allocatable.pods}{" pods\n"}{end}' 2>/dev/null | head -n 15 || true
```

**Expected:** **Resources** **docs**; **per-node** **allocatable** **pod** **capacity** **(related** **scheduling** **pressure**, **not** **PIDs** **directly**).

## Video close — fast validation

```bash
kubectl get pods -A --field-selector=status.phase=Running 2>/dev/null | wc -l 2>/dev/null || true
```

## Troubleshooting

- **Resource exhausted: pids** → raise pod PIDs limit (platform) or fix app thread leaks
- **No** **visibility** **into** **limits** **from** **API** → **node** **SSH**, **cloud** **node** **pool** **docs**, **or** **support** **ticket**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-9-3-process-id-limits-and-reservations-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-9-3-process-id-limits-and-reservations-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.9.4 Node Resource Managers](../04-node-resource-managers/README.md)
