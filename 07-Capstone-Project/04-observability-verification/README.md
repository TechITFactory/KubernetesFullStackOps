# Observability and scaling — teaching transcript

## Intro

**Traffic** **spikes** **need** **horizontal** **scale** **without** **manual** **`kubectl scale`**. **This** **lesson** **applies** **`capstone-frontend-hpa`** **in** **`capstone-prod`**, **targeting** **`Deployment/capstone-frontend`**, **CPU** **average** **utilization** **`70%`**, **`minReplicas: 2`**, **`maxReplicas: 8`**. **You** **need** **`metrics-server`** **(or** **equivalent** **metrics** **API)** **for** **meaningful** **`kubectl get hpa`**.

**Prerequisites:** [7.3 Security enforcement](../03-security-enforcement/README.md); [6.3 Autoscaling decisions](../../06-Observability-and-Reliability/03-autoscaling-decisions/README.md).

## Flow of this lesson

```
  capstone-frontend Deployment running with CPU requests
              │
              ▼
  HPA observes metrics → scales between min and max
              │
              ▼
  kubectl get hpa -w shows reaction to load
```

**Say:**

**`minReplicas: 2` matches** **the** **Deployment** **default** **in** **[7.1](../01-deploy-enterprise-app/README.md)** **—** **HPA** **will** **not** **scale** **below** **two** **unless** **you** **change** **the** **spec**.

## Learning objective

- **Apply** **`capstone-hpa.yaml`** **and** **read** **`kubectl get hpa`** **output** **for** **the** **capstone** **frontend**.

## Why this matters

**Flash** **sales** **and** **DDoS-ish** **legitimate** **traffic** **both** **look** **like** **CPU** **graphs** **—** **HPA** **is** **the** **first** **automatic** **relief** **valve**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/07-Capstone-Project/04-observability-verification" 2>/dev/null || cd .
```

## Step 1 — Inspect the HPA

**What happens when you run this:**

**Validates** **target** **name**, **namespace**, **and** **thresholds**.

**Run:**

```bash
cat yamls/capstone-hpa.yaml
```

**Expected:** **`scaleTargetRef.name: capstone-frontend`**, **`namespace: capstone-prod`**, **`minReplicas: 2`**, **`maxReplicas: 8`**, **`averageUtilization: 70`**.

---

## Step 2 — Apply

**What happens when you run this:**

**Registers** **the** **HPA** **in** **`capstone-prod`**.

**Run:**

```bash
kubectl apply -f yamls/capstone-hpa.yaml
kubectl get hpa -n capstone-prod
```

**Expected:** **`capstone-frontend-hpa`** **row** **present**.

---

## Step 3 — Watch (optional)

**What happens when you run this:**

**Observe** **replica** **changes** **under** **load** **(generate** **load** **externally** **if** **you** **want** **motion)**.

**Run:**

```bash
kubectl get hpa -n capstone-prod -w
```

**Expected:** **Stable** **replicas** **at** **idle** **;** **possible** **scale** **up** **under** **stress**.

## Video close — fast validation

**What happens when you run this:**

**Deletes** **the** **HPA**.

**Run:**

```bash
kubectl delete -f yamls/capstone-hpa.yaml --ignore-not-found
```

**Expected:** **HPA** **removed**.

## Troubleshooting

- **`unknown/70%`** → **metrics-server** **missing** **or** **metrics** **RBAC**
- **No** **scale** **above** **2** → **CPU** **not** **high** **enough**, **requests** **too** **small**, **or** **`maxReplicas` hit**
- **Deployment** **missing** → **re-run** **[7.1](../01-deploy-enterprise-app/README.md)**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/capstone-hpa.yaml` | **HPA** **for** **`capstone-frontend`** |

## Cleanup

```bash
kubectl delete -f yamls/capstone-hpa.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[7.5 The final defense](../05-final-defense/README.md)
