# Autoscaling decisions — teaching transcript

## Intro

**HorizontalPodAutoscaler** **(HPA)** **scales** **a** **`Deployment`** **(or** **similar** **workload)** **based** **on** **observed** **metrics** **—** **commonly** **CPU** **or** **memory** **utilization** **from** **metrics-server**. **This** **lesson** **deploys** **`stress-app`** **(CPU** **stress** **image)** **and** **`auto-scaler-demo`** **HPA** **targeting** **50%** **average** **CPU** **between** **1** **and** **10** **replicas**. **You** **need** **metrics-server** **for** **meaningful** **`kubectl get hpa`**.

**Prerequisites:** [6.2 Alerting and SLOs](../02-alerting-and-slos/README.md); **[metrics-server](https://github.com/kubernetes-sigs/metrics-server)** **installed**; [Track 2 workloads](../../02-Core-Workloads/README.md) **(Deployments)**.

## Flow of this lesson

```
  Deployment with CPU load
              │
              ▼
  HPA reads metrics API → compares to targetUtilization
              │
              ▼
  Deployment replicas increase until under threshold or maxReplicas
```

**Say:**

**`kubectl get hpa -w` is** **the** **movie** **—** **students** **should** **see** **TARGETS** **cross** **50%** **then** **REPLICAS** **climb**.

## Learning objective

- **Apply** **`stress-deployment.yaml`** **and** **`cpu-hpa.yaml`** **together**.
- **Interpret** **`kubectl get hpa`** **columns** **including** **`TARGETS`** **and** **`REPLICAS`**.

## Why this matters

**Marketing** **events** **and** **traffic** **spikes** **are** **not** **scheduled** **in** **your** **calendar** **—** **HPA** **is** **the** **default** **elastic** **response**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/06-Observability-and-Reliability/03-autoscaling-decisions" 2>/dev/null || cd .
```

## Step 1 — Deploy the stress workload

**What happens when you run this:**

**Creates** **`stress-app`** **Deployment** **with** **`vish/stress`** **and** **CPU** **requests**/**limits**.

**Run:**

```bash
kubectl apply -f yamls/stress-deployment.yaml
kubectl get deploy stress-app
kubectl get pods -l app=stress
```

**Expected:** **One** **Pod** **running** **(after** **pull)**.

---

## Step 2 — Apply the HPA

**What happens when you run this:**

**Binds** **HPA** **`auto-scaler-demo`** **to** **`Deployment/stress-app`**, **target** **50%** **CPU**, **min** **1**, **max** **10**.

**Run:**

```bash
cat yamls/cpu-hpa.yaml
kubectl apply -f yamls/cpu-hpa.yaml
kubectl get hpa auto-scaler-demo
```

**Expected:** **HPA** **row** **shows** **targets** **(may** **show** **`unknown`** **without** **metrics-server)**.

---

## Step 3 — Watch scaling (metrics-server required)

**What happens when you run this:**

**Live** **watch** **until** **replicas** **react** **or** **you** **stop** **with** **Ctrl+C**.

**Run:**

```bash
kubectl get hpa auto-scaler-demo -w
```

**Expected:** **After** **metrics** **populate**, **`REPLICAS`** **may** **increase** **when** **average** **CPU** **exceeds** **target**.

## Video close — fast validation

**What happens when you run this:**

**Deletes** **HPA** **then** **Deployment**.

**Run:**

```bash
kubectl delete -f yamls/cpu-hpa.yaml --ignore-not-found
kubectl delete -f yamls/stress-deployment.yaml --ignore-not-found
```

**Expected:** **Objects** **removed**.

## Troubleshooting

- **`TARGETS` shows** **`<unknown>/50%`** → **install** **or** **repair** **metrics-server**; **check** **kubelet** **and** **aggregated** **metrics** **RBAC**
- **No** **scale** **up** → **insufficient** **load**, **requests** **too** **low**, **or** **`maxReplicas` reached**
- **`vish/stress` pull** **blocked** → **mirror** **or** **swap** **image** **in** **restricted** **clusters**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/stress-deployment.yaml` | **`stress-app`** **CPU** **burner** |
| `yamls/cpu-hpa.yaml` | **HPA** **`auto-scaler-demo`** |

## Cleanup

```bash
kubectl delete -f yamls/cpu-hpa.yaml --ignore-not-found 2>/dev/null || true
kubectl delete -f yamls/stress-deployment.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[6.4 Backup and DR](../04-backup-and-dr/README.md)
