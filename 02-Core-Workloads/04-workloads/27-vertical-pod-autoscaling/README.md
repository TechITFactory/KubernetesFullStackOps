# 2.4.5.2 Vertical Pod Autoscaling â€” teaching transcript

## Intro

**VPA** recommends or applies **right-sized CPU/memory requests** for containers based on historical and live usage. The usual components are **Recommender** (computes advice), **Updater** (evicts pods so new ones pick up new requests), and **Admission** (mutates pod create requests to inject recommendations). **`updateMode: Off`** exposes recommendations onlyâ€”safe for learning. **`Initial`** applies on pod creation. **`Auto`** can evict running pods to recreate them with new requestsâ€”operationally noisy. **Never run VPA and HPA on the same workload on the same resource dimension** (for example both driving **CPU**); they fight and are **unsupported** together for CPU/memory in standard guidance.

**Prerequisites:** [2.4.5.1 HPA](../26-horizontal-pod-autoscaling/README.md) (contrast); VPA controller installed on cluster.

## Flow of this lesson

```
  Workload usage observed
         â”‚
         â–¼
  VPA Recommender â†’ recommendation object
         â”‚
         â”œâ”€â”€ updateMode Off â†’ human reads only
         â”œâ”€â”€ Initial â†’ admission on create
         â””â”€â”€ Auto â†’ updater evicts â†’ new pod sizes
```

**Say:**

Treat **Auto** as a **rolling restart machine**â€”notify app owners before enabling.

## Learning objective

- Name **Recommender**, **Updater**, and **Admission** roles.
- Compare **`updateMode`** values **Off**, **Initial**, and **Auto**.
- State the **HPA + VPA** conflict on **CPU/memory**.

## Why this matters

Right-sizing saves money; blind **Auto** mode breaks latency-sensitive apps during eviction storms.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/part-2-concepts/2.4-workloads/25-autoscaling-workloads/27-vertical-pod-autoscaling" 2>/dev/null || cd .
```

## Step 1 â€” Ensure sample Deployment

**What happens when you run this:**

Same **`manage-workloads-demo`** Deployment gives VPA something to target.

**Say:**

If **VPA CRD** is missing, stop here and install upstream **VPA** manifests for your environment.

**Run:**

```bash
kubectl apply -f ../24-managing-workloads/yamls/manage-workloads-demo.yaml
```

**Expected:** Deployment present.

---

## Step 2 â€” Apply VPA object

**What happens when you run this:**

Creates **`VerticalPodAutoscaler`** `vpa-demo` if CRDs exist.

**Say:**

**`kubectl explain verticalpodautoscaler`** confirms fields for your API version.

**Run:**

```bash
kubectl apply -f yamls/vpa-demo.yaml
kubectl get verticalpodautoscaler.autoscaling.k8s.io vpa-demo
```

**Expected:** VPA listed when CRDs/controller installed; otherwise API discovery error instructing install.

---

## Step 3 â€” Describe recommendations (when available)

**What happens when you run this:**

`describe` prints **Recommendation** blocks when the recommender has data.

**Say:**

**Off** mode still populates **status** over timeâ€”no eviction required.

**Run:**

```bash
kubectl api-resources | grep -i verticalpodautoscaler || true
kubectl describe vpa vpa-demo 2>/dev/null || true
```

**Expected:** CRD presence confirmed; describe shows content or â€œnot foundâ€ if install incomplete.

## Video close â€” fast validation

```bash
kubectl api-resources | grep -i verticalpodautoscaler || true
kubectl describe vpa vpa-demo 2>/dev/null || true
```

## Troubleshooting

- **CRD not found** â†’ install VPA release matching cluster version
- **No recommendations** â†’ wait for metrics; ensure target pods have **usage**
- **Unexpected evictions** â†’ switch **`updateMode`** to **Off** or **Initial**
- **Webhook errors on create** â†’ VPA admission misconfigured; check certs and failure policy
- **HPA + VPA conflict** â†’ disable one controllerâ€™s CPU/memory loop or split concerns (e.g., HPA on custom metric only with care)
- **OOM after VPA lowers requests** â†’ recommender needs more history; set **minAllowed**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/vpa-demo.yaml` | Sample VPA targeting manage demo |
| `yamls/failure-troubleshooting.yaml` | Webhook and CRD issues |

## Cleanup

```bash
kubectl delete vpa vpa-demo --ignore-not-found 2>/dev/null || true
```

## Next

[2.5 Services, Load Balancing, and Networking](../../2.5-services-load-balancing-and-networking/README.md)
