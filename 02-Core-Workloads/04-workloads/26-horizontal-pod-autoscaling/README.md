# 2.4.5.1 Horizontal Pod Autoscaling â€” teaching transcript

## Intro

**HPA** scales a **Deployment**, **StatefulSet**, **ReplicaSet**, or similar **scale subresource** by changing **`.spec.replicas`** when observed metrics exceed targets. **CPU percentage** targets need **metrics-server** (or equivalent) and **CPU requests** on the Pod templateâ€”without requests, utilization is undefined. HPA applies **stabilization windows** so scale-up and scale-down are not twitchy on brief spikes. If **HPA manages** a Deployment, **do not hard-code `replicas` in Git** to a fixed value and expect it to stickâ€”HPA **overwrites** replicas unless you use server-side apply patterns that surrender that field. **Custom metrics** and **KEDA** extend the same idea to queue depth and external signals; this lab sticks to the bundled **`hpa-demo.yaml`**.

**Prerequisites:** [2.4.5 module](../README.md); [2.4.4 manage demo](../24-managing-workloads/README.md) supplies `manage-workloads-demo`.

## Flow of this lesson

```
  metrics-server (or vendor) â”€â”€â–º metrics API
              â”‚
              â–¼
  HPA reads Deployment scale + CPU/memory/custom
              â”‚
              â–¼
  Writes spec.replicas on target workload
```

**Say:**

I say out loud: **replicas become control-loop output**, not static YAML, once HPA attaches.

## Learning objective

- State **metrics-server** (or equivalent) as prerequisite for resource metrics.
- Interpret **`targetCPUUtilizationPercentage`** (or `metrics` array on newer API).
- Explain **stabilization windows** at a high level.
- Warn against pinning **`replicas`** while HPA owns the field.
- Mention **KEDA** as the common path for **custom** scale metrics.

## Why this matters

HPA is the default answer to traffic spikes; misconfigured targets cause either **cost blowouts** or **brownouts**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/part-2-concepts/2.4-workloads/25-autoscaling-workloads/26-horizontal-pod-autoscaling" 2>/dev/null || cd .
```

## Step 1 â€” Ensure target Deployment exists

**What happens when you run this:**

The HPA manifest references **`Deployment/manage-workloads-demo`**; the manage demo YAML provides it.

**Say:**

If you skipped [2.4.4](../24-managing-workloads/README.md), this apply still worksâ€”the path points at the static manifest.

**Run:**

```bash
kubectl apply -f ../24-managing-workloads/yamls/manage-workloads-demo.yaml
kubectl rollout status deployment/manage-workloads-demo --timeout=120s
```

**Expected:** Deployment available with replicas from that manifest.

---

## Step 2 â€” Apply HPA and inspect

**What happens when you run this:**

`HorizontalPodAutoscaler` binds to the Deployment; **CPU** metrics stay `<unknown>` until metrics-server works.

**Say:**

On **Minikube**, I often add **`minikube addons enable metrics-server`** before filming scale behavior.

**Run:**

```bash
kubectl apply -f yamls/hpa-demo.yaml
kubectl get hpa hpa-demo
```

**Expected:** HPA object exists and references `Deployment/manage-workloads-demo`.

---

## Step 3 â€” Metrics sanity (optional)

**What happens when you run this:**

`kubectl top` proves the metrics pipelineâ€”often fails on fresh **Kind** without metrics-server.

**Say:**

**`<unknown>`** in `kubectl describe hpa` almost always means **metrics** or **requests** missing.

**Run:**

```bash
kubectl describe hpa hpa-demo | sed -n '/Metrics:/,/Events:/p'
kubectl top pods 2>/dev/null || true
```

**Expected:** Metrics section shows targets; `top` prints usage when metrics-server is healthy.

## Video close â€” fast validation

```bash
kubectl get hpa
kubectl describe hpa hpa-demo | sed -n '/Metrics:/,/Events:/p'
kubectl top pods 2>/dev/null || true
```

## Troubleshooting

- **`FailedGetResourceMetric`** â†’ install **metrics-server**; verify **Pod has CPU request**
- **Replicas snap back in GitOps** â†’ remove static **replicas** from apply or use policy that ignores the field
- **Slow scale down** â†’ default **downscale stabilization**; tune HPA behavior per docs
- **HPA ignores peak** â†’ increase **behavior.scaleUp** or lower target; validate metric lag
- **Wrong Deployment name** â†’ edit `scaleTargetRef` in `yamls/hpa-demo.yaml`
- **Custom metric needs** â†’ evaluate **KEDA** instead of cramming logic into CPU-only HPA

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/hpa-demo.yaml` | Sample HPA targeting manage demo |
| `yamls/failure-troubleshooting.yaml` | Metrics and reference mistakes |

## Cleanup

```bash
kubectl delete hpa hpa-demo --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.5.2 Vertical Pod Autoscaling](../27-vertical-pod-autoscaling/README.md)
