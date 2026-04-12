# Deploy enterprise application — teaching transcript

## Intro

**You** **stand** **up** **a** **minimal** **two-tier** **demo** **in** **`capstone-prod`:** **`redis-master`** **(Deployment** **+** **ClusterIP** **Service)** **and** **`capstone-frontend`** **(nginx** **Deployment** **with** **`REDIS_HOST`**, **plus** **a** **`NodePort`** **Service)**. **The** **scenario** **frames** **you** **as** **lead** **SRE** **for** **a** **launch** **—** **the** **YAML** **is** **intentionally** **small** **so** **you** **can** **reason** **about** **every** **field**.

**Prerequisites:** [Track 7 module](../README.md); [Track 2: Core workloads](../../02-Core-Workloads/README.md) **(Deployments** **and** **Services)**.

## Flow of this lesson

```
  kubectl create namespace capstone-prod
              │
              ▼
  apply redis-backend.yaml → apply python-frontend.yaml
              │
              ▼
  kubectl get all -n capstone-prod
```

**Say:**

**The** **frontend** **manifest** **filename** **says** **`python`** **but** **the** **container** **image** **is** **`nginx`** **—** **read** **the** **file** **before** **you** **narrate** **the** **stack**.

## Learning objective

- **Create** **`capstone-prod`** **and** **apply** **both** **manifest** **files** **in** **order**.
- **Verify** **Deployments**, **Services**, **and** **Pods** **reach** **Ready**.

## Why this matters

**Later** **phases** **assume** **`redis-master`** **DNS** **and** **`app: frontend` / `app: redis` labels** **—** **if** **7.1** **is** **wrong**, **everything** **else** **wobbles**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/07-Capstone-Project/01-deploy-enterprise-app" 2>/dev/null || cd .
```

## Step 1 — Create the namespace

**What happens when you run this:**

**Creates** **`capstone-prod`** **for** **all** **capstone** **objects**.

**Run:**

```bash
kubectl create namespace capstone-prod 2>/dev/null || true
kubectl get ns capstone-prod
```

**Expected:** **Namespace** **`capstone-prod`** **exists**.

---

## Step 2 — Deploy Redis and frontend

**What happens when you run this:**

**Applies** **Redis** **and** **frontend** **manifests** **into** **`capstone-prod`**.

**Run:**

```bash
kubectl apply -f yamls/redis-backend.yaml -n capstone-prod
kubectl apply -f yamls/python-frontend.yaml -n capstone-prod
```

**Expected:** **Deployments** **`redis-master`**, **`capstone-frontend`** **and** **matching** **Services** **created**.

---

## Step 3 — Verify

**What happens when you run this:**

**Lists** **core** **objects** **in** **the** **namespace**.

**Run:**

```bash
kubectl get all -n capstone-prod
kubectl get endpoints -n capstone-prod
```

**Expected:** **Pods** **Running**; **endpoints** **show** **IPs** **for** **`redis-master`** **and** **`capstone-frontend`**.

## Video close — fast validation

**What happens when you run this:**

**Optional** **full** **teardown** **between** **practice** **runs** **(deletes** **everything** **in** **the** **namespace** **including** **later** **labs)**.

**Run:**

```bash
kubectl delete namespace capstone-prod --ignore-not-found
```

**Expected:** **Namespace** **terminating** **or** **gone**.

## Troubleshooting

- **`ImagePullBackOff`** → **registry** **policy**, **offline** **cluster**, **or** **wrong** **arch**
- **No** **endpoints** **on** **Service** → **selector** **mismatch** **or** **Pods** **not** **Ready**
- **NodePort** **unreachable** → **cloud** **SG**, **local** **firewall**, **or** **`minikube service`**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/redis-backend.yaml` | **Redis** **Deployment** **+** **`redis-master`** **Service** |
| `yamls/python-frontend.yaml` | **Frontend** **Deployment** **+** **`capstone-frontend`** **Service** **(nginx)** |

## Cleanup

```bash
kubectl delete namespace capstone-prod --ignore-not-found 2>/dev/null || true
```

## Next

[7.2 CI/CD and GitOps flow](../02-cicd-gitops-flow/README.md)
