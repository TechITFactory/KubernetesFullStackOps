# 2.11.2 Swap memory management — teaching transcript

## Intro

**Swap** **on** **Linux** **nodes** **historically** **conflicted** **with** **Kubernetes** **memory** **accounting** **and** **predictable** **latency**. **Modern** **Kubernetes** **can** **run** **with** **limited**, **configured** **swap** **on** **the** **node** **when** **feature** **gates** **and** **kubelet** **settings** **allow** **it**—**still** **treat** **swap** **as** **a** **policy** **decision** **(latency** **vs** **burst** **headroom)** **not** **a** **default** **toggle**.

**Prerequisites:** [2.11.1 Node shutdowns](../01-node-shutdowns/README.md); [2.7.4 Resource management for pods and containers](../../07-configuration/04-resource-management-for-pods-and-containers/README.md).

## Flow of this lesson

```
  Node memory pressure + swap configuration
              │
              ▼
  kubelet cgroup behavior and eviction thresholds
              │
              ▼
  Workload SLO risk if swap hides true RAM pressure
```

**Say:**

**If** **swap** **masks** **OOM** **signals**, **HPA** **and** **SRE** **dashboards** **lie**—**I** **document** **whether** **swap** **is** **on** **per** **node** **pool**.

## Learning objective

- Explain **why** **swap** **interacts** **with** **memory** **limits** **and** **eviction**.
- Correlate **node** **conditions** **with** **memory** **pressure** **(read-only** **`kubectl`)**.

## Why this matters

**Silent** **paging** **turns** **sub-millisecond** **RPCs** **into** **seconds** **without** **crossing** ** cgroup** **memory** **limits**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/11-cluster-administration/02-swap-memory-management" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-11-2-swap-memory-management-notes.yaml
kubectl get cm -n kube-system 2-11-2-swap-memory-management-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-11-2-swap-memory-management-notes`** when allowed.

---

## Step 2 — Node memory signals (read-only)

**What happens when you run this:**

**JSONPath** **filters** **memory-related** **conditions** **when** **present**.

**Run:**

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{range .status.conditions[*]}{.type}{"\t"}{.status}{"\n"}{end}{"\n"}{end}' 2>/dev/null | grep -i Memory | head -n 20 || true
kubectl top nodes 2>/dev/null | head -n 10 || true
```

**Expected:** **Condition** **lines** **or** **empty**; **`top`** **requires** **metrics-server**.

## Video close — fast validation

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.allocatable.memory}{"\n"}{end}' 2>/dev/null | head -n 10 || true
```

## Troubleshooting

- **`top` fails** → **install** **or** **skip** **metrics** **demo**
- **Swap** **policy** **in** **docs** **only** → **SSH** **to** **node** **for** **`swapon`** **(out** **of** **band)**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-11-2-swap-memory-management-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-11-2-swap-memory-management-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.11.3 Node autoscaling](../03-node-autoscaling/README.md)
