# The final defense — teaching transcript

## Intro

**A** **scripted** **“chaos”** **step** **deletes** **`Service/redis-master`** **in** **`capstone-prod`**, **simulating** **accidental** **destruction** **of** **the** **data** **plane** **network** **front** **door**. **Your** **job** **is** **to** **notice** **missing** **endpoints**, **re-apply** **the** **known-good** **manifest** **from** **[7.1](../01-deploy-enterprise-app/README.md)**, **and** **confirm** **traffic** **paths** **recover**. **Requires** **`kubectl`** **configured** **and** **`bash`**.

**Prerequisites:** [7.4 Observability and scaling](../04-observability-verification/README.md); **[7.1](../01-deploy-enterprise-app/README.md)** **manifests** **still** **on** **disk**.

## Flow of this lesson

```
  chaos-monkey.sh → kubectl delete service redis-master
              │
              ▼
  kubectl get all / endpoints → missing Service
              │
              ▼
  kubectl apply redis-backend.yaml → Service restored
```

**Say:**

**Real** **chaos** **engineering** **needs** **blast** **radius** **controls** **and** **approval** **—** **this** **script** **is** **a** **toy** **for** **one** **namespace** **only**.

## Learning objective

- **Execute** **`scripts/chaos-monkey.sh`**, **diagnose** **with** **`kubectl`**, **and** **restore** **`redis-master`** **from** **the** **baseline** **YAML** **in** **[7.1](../01-deploy-enterprise-app/README.md)**.

## Why this matters

**Incidents** **are** **timed** **tests** **of** **whether** **your** **artifacts** **and** **runbooks** **actually** **work** **—** **not** **whether** **you** **memorized** **slides**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/07-Capstone-Project/05-final-defense" 2>/dev/null || cd .
```

## Step 1 — Run the chaos script

**What happens when you run this:**

**Deletes** **`service/redis-master`** **in** **`capstone-prod`** **(silent** **on** **failure** **if** **already** **gone)**.

**Run:**

```bash
bash scripts/chaos-monkey.sh
```

**Expected:** **Console** **messages** **from** **script**; **`redis-master`** **Service** **absent**.

---

## Step 2 — Triage

**What happens when you run this:**

**Shows** **whether** **Pods** **still** **run** **while** **the** **Service** **is** **missing**.

**Run:**

```bash
kubectl get all -n capstone-prod
kubectl get endpoints -n capstone-prod
```

**Expected:** **Redis** **Pods** **may** **still** **exist** **;** **`redis-master`** **endpoints** **empty** **or** **missing**.

---

## Step 3 — Restore from baseline YAML

**What happens when you run this:**

**Re-applies** **the** **Redis** **Deployment** **and** **Service** **from** **phase** **7.1**.

**Run:**

```bash
kubectl apply -f ../01-deploy-enterprise-app/yamls/redis-backend.yaml -n capstone-prod
```

**Expected:** **`redis-master`** **Service** **recreated** **;** **Deployment** **unchanged** **or** **reconciled**.

---

## Step 4 — Validate endpoints

**What happens when you run this:**

**Confirms** **the** **Service** **again** **has** **backend** **Pod** **IPs**.

**Run:**

```bash
kubectl get endpoints redis-master -n capstone-prod -o wide
```

**Expected:** **Non-empty** **subsets** **with** **Redis** **Pod** **IPs**.

## Video close — fast validation

**What happens when you run this:**

**Optional** **full** **namespace** **delete** **when** **you** **are** **done** **with** **the** **entire** **capstone**.

**Run:**

```bash
kubectl delete namespace capstone-prod --ignore-not-found
```

**Expected:** **Namespace** **removed**.

## Troubleshooting

- **`chaos-monkey.sh` permission** **denied** → **`chmod +x scripts/chaos-monkey.sh`** **or** **`bash scripts/chaos-monkey.sh`**
- **Wrong** **context** → **`kubectl config current-context`**
- **Apply** **still** **no** **endpoints** → **Pods** **not** **Ready** **or** **selector** **mismatch**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/chaos-monkey.sh` | **Deletes** **`redis-master`** **Service** **(lab** **chaos)** |

## Cleanup

```bash
kubectl apply -f ../01-deploy-enterprise-app/yamls/redis-backend.yaml -n capstone-prod 2>/dev/null || true
kubectl delete namespace capstone-prod --ignore-not-found 2>/dev/null || true
```

## Next

[Course overview and further tracks](../../README.md)
