# 2.10.5 Pod Topology Spread Constraints — teaching transcript

## Intro

**Topology** **spread** **constraints** **skew** **replica** **placement** **across** **domains** **(zones**, **nodes**, **custom** **labels)** **using** **`maxSkew`**, **`topologyKey`**, **`whenUnsatisfiable`**, **and** **label** **selectors**. **`DoNotSchedule`** **behaves** **like** **a** **hard** **constraint**; **`ScheduleAnyway`** **prefers** **balance** **but** **can** **pack** **when** **necessary**. **Combine** **spread** **with** **Pod** **anti-affinity** **carefully**—**both** **can** **make** **feasible** **sets** **empty**.

**Prerequisites:** [2.10.4 Pod Scheduling Readiness](../04-pod-scheduling-readiness/README.md).

## Flow of this lesson

```
  Deployment replicas + topologySpreadConstraints
              │
              ▼
  Scheduler balances counts per topology domain
              │
              ▼
  Imbalance tolerated up to maxSkew (per rules)
```

**Say:**

**Zonal** **outages** **are** **the** **motivation**—**I** **show** **`topology.kubernetes.io/zone`** **on** **nodes** **before** **the** **constraint** **YAML**.

## Learning objective

- Use **`kubectl explain`** **for** **`pod.spec.topologySpreadConstraints`**.
- Contrast **`whenUnsatisfiable`** **modes** **in** **plain** **language**.

## Why this matters

**Spread** **without** **enough** **zones** **or** **nodes** **blocks** **scaling** **exactly** **like** **over-tight** **affinity**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/10-scheduling-preemption-and-eviction/05-pod-topology-spread-constraints" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-10-5-pod-topology-spread-constraints-notes.yaml
kubectl get cm -n kube-system 2-10-5-pod-topology-spread-constraints-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-10-5-pod-topology-spread-constraints-notes`** when allowed.

---

## Step 2 — Explain spread constraints and node topology labels (read-only)

**What happens when you run this:**

**API** **shape** **plus** **real** **`topology.kubernetes.io/zone`** **values** **when** **present**.

**Run:**

```bash
kubectl explain pod.spec.topologySpreadConstraints 2>/dev/null | head -n 40 || true
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.topology\.kubernetes\.io/zone}{"\n"}{end}' 2>/dev/null | head -n 15 || true
```

**Expected:** **Explain** **output**; **zone** **column** **per** **node** **(may** **be** **empty**).

## Video close — fast validation

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.topology\.kubernetes\.io/zone}{"\n"}{end}' 2>/dev/null | head -n 10 || true
```

## Troubleshooting

- **`FailedScheduling` skew** → **increase** **`maxSkew`**, **add** **capacity**, **or** **use** **`ScheduleAnyway`**
- **No** **zone** **labels** → **cloud** **provider** **does** **not** **expose** **topology** **(teach** **fallback** **keys)**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-10-5-pod-topology-spread-constraints-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-10-5-pod-topology-spread-constraints-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.10.6 Taints and Tolerations](../06-taints-and-tolerations/README.md)
