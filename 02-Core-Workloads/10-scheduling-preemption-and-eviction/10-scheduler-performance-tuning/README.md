# 2.10.10 Scheduler Performance Tuning — teaching transcript

## Intro

**Scheduler** **performance** **tuning** **addresses** **latency** **from** **large** **cluster** **fan-out**: **percentage** **of** **nodes** **to** **score**, **parallelism**, **profile** **levels**, **and** **plugin** **cost**. **Very** **large** **clusters** **may** **disable** **expensive** **scoring** **plugins** **or** **reduce** **candidate** **node** **lists** **after** **filtering**. **Configuration** **lives** **in** **`KubeSchedulerConfiguration`** **on** **the** **control** **plane**—**managed** **Kubernetes** **hides** **these** **knobs** **behind** **cloud** **SLOs** **and** **support** **tickets**.

**Prerequisites:** [2.10.9 Gang Scheduling](../09-gang-scheduling/README.md).

## Flow of this lesson

```
  Scheduling throughput = (Pods/s) bound with SLO
              │
              ▼
  Tune: node percentage to score, parallelism, plugin sets
              │
              ▼
  Measure: scheduler latency metrics + scheduling latency histograms
```

**Say:**

**When** **`kubectl get pods` shows** **thousands** **Pending** **during** **a** **deploy**, **first** **check** **capacity**—**then** **ask** **whether** **the** **scheduler** **is** **CPU-throttled** **or** **misconfigured**.

## Learning objective

- List **representative** **scheduler** **tuning** **dimensions** **without** **pretending** **every** **cluster** **exposes** **them**.
- Use **`kubectl`** **to** **spot** **symptoms** **(Pending** **storms**, **event** **rates)** **that** **justify** **platform** **tuning**.

## Why this matters

**Black** **Friday** **scale** **events** **expose** **scheduler** **hot** **paths** **before** **HPA** **or** **CA** **matter**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/10-scheduling-preemption-and-eviction/10-scheduler-performance-tuning" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-10-10-scheduler-performance-tuning-notes.yaml
kubectl get cm -n kube-system 2-10-10-scheduler-performance-tuning-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-10-10-scheduler-performance-tuning-notes`** when allowed.

---

## Step 2 — Pending Pod pressure snapshot (read-only)

**What happens when you run this:**

**Rough** **indicator** **of** **scheduling** **queue** **depth** **from** **the** **API** **surface**.

**Run:**

```bash
kubectl get pods -A --field-selector=status.phase=Pending --no-headers 2>/dev/null | wc -l 2>/dev/null || true
kubectl get nodes --no-headers 2>/dev/null | wc -l 2>/dev/null || true
```

**Expected:** **Counts** **(integers)** **for** **discussion** **of** **scale**.

## Video close — fast validation

```bash
kubectl get lease -n kube-system 2>/dev/null | grep -i scheduler | head -n 3 || true
```

## Troubleshooting

- **High** **Pending** **with** **clear** **`FailedScheduling`** → **policy** **issue**, **not** **throughput**
- **High** **Pending** **without** **clear** **messages** → **control** **plane** **saturation** **or** **API** **latency**
- **`wc` on Windows** → **Git** **Bash** **or** **WSL** **for** **same** **one-liners**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-10-10-scheduler-performance-tuning-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-10-10-scheduler-performance-tuning-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.10.11 Resource Bin Packing](../11-resource-bin-packing/README.md)
