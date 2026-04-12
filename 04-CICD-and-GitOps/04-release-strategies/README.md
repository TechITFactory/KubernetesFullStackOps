# Release strategies — teaching transcript

## Intro

**Blue/green** **keeps** **two** **versions** **of** **the** **app** **running** **at** **once** **and** **moves** **user** **traffic** **by** **changing** **a** **`Service`** **`selector`** **(or** **equivalent** **load** **balancer** **rule)** **—** **no** **Pods** **need** **to** **restart** **for** **the** **cutover**. **This** **lesson** **uses** **`blue-app`** **and** **`green-app`** **Deployments** **plus** **`active-color-service`** **pointing** **at** **`version: blue`**. **Flipping** **to** **`version: green`** **routes** **to** **the** **other** **ReplicaSet** **instantly** **(modulo** **connection** **draining** **and** **client** **caching)**.

**Prerequisites:** [4.3 Progressive delivery](../03-progressive-delivery/README.md); **[Track** **2](../../02-Core-Workloads/README.md)** **(Deployments**, **Services**, **Endpoints)**.

## Flow of this lesson

```
  blue-app + green-app Deployments (both Ready)
              │
              ▼
  Service selector app=colors, version=blue
              │
              ▼
  Edit selector to version=green → traffic follows green endpoints
```

**Say:**

**Endpoints** **are** **the** **truth** **—** **`kubectl get endpoints`** **shows** **which** **Pod** **IPs** **the** **Service** **actually** **targets**.

## Learning objective

- **Apply** **two** **versioned** **Deployments** **and** **one** **front** **`Service`** **from** **repo** **YAML**.
- **Verify** **traffic** **with** **`kubectl get endpoints`**, **then** **flip** **the** **selector** **to** **green**.

## Why this matters

**Controllers** **like** **Argo** **Rollouts** **automate** **what** **you** **must** **understand** **by** **hand** **first** **—** **otherwise** **automation** **feels** **like** **a** **black** **box**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/04-CICD-and-GitOps/04-release-strategies" 2>/dev/null || cd .
```

## Step 1 — Deploy blue and green

**What happens when you run this:**

**Creates** **`blue-app`** **(nginx** **1.24)** **and** **`green-app`** **(nginx** **1.25)** **with** **distinct** **`version`** **labels**.

**Run:**

```bash
kubectl apply -f yamls/blue-deployment.yaml
kubectl apply -f yamls/green-deployment.yaml
kubectl get deploy blue-app green-app
kubectl get pods -l app=colors -o wide
```

**Expected:** **Both** **Deployments** **ready** **;** **four** **Pods** **total** **(two** **per** **color)** **when** **replicas** **default** **to** **2** **each**.

---

## Step 2 — Apply the active Service

**What happens when you run this:**

**Creates** **`active-color-service`** **selecting** **`app: colors`** **and** **`version: blue`**.

**Say:**

**The** **comment** **in** **`active-service.yaml`** **is** **the** **runbook** **—** **change** **one** **label** **value** **to** **switch** **production**.

**Run:**

```bash
cat yamls/active-service.yaml
kubectl apply -f yamls/active-service.yaml
```

**Expected:** **ClusterIP** **Service** **exists** **;** **YAML** **shows** **`version: blue`**.

---

## Step 3 — Verify traffic targets blue

**What happens when you run this:**

**Endpoints** **list** **Pod** **IPs** **that** **match** **the** **Service** **selector** **—** **only** **blue** **Pods** **should** **appear**.

**Run:**

```bash
kubectl get endpoints active-color-service -o wide
kubectl get pods -l version=blue -o wide
```

**Expected:** **Endpoint** **subsets** **reference** **blue** **Pod** **IPs** **only**.

---

## Step 4 — Flip to green

**What happens when you run this:**

**You** **change** **`spec.selector.version`** **from** **`blue`** **to** **`green`** **(edit** **file** **and** **`kubectl apply`**, **or** **`kubectl patch`**, **or** **`kubectl edit service active-color-service`)**.

**Say:**

**Pods** **stay** **running** **;** **only** **the** **Service** **wiring** **changes** **—** **that** **is** **the** **blue/green** **promise**.

**Run:**

```bash
kubectl patch service active-color-service -p '{"spec":{"selector":{"app":"colors","version":"green"}}}'
```

**Expected:** **Endpoints** **update** **to** **green** **Pod** **IPs** **(after** **brief** **propagation)**.

---

## Step 5 — Confirm green endpoints

**What happens when you run this:**

**Re-check** **endpoints** **and** **green** **Pods**.

**Run:**

```bash
kubectl get endpoints active-color-service
kubectl get pods -l version=green -o wide
```

**Expected:** **Service** **now** **targets** **green** **replicas**.

## Video close — fast validation

**What happens when you run this:**

**Tears** **down** **Deployments**, **then** **the** **Service** **(order** **avoids** **orphan** **selector** **confusion** **in** **some** **setups)**.

**Run:**

```bash
kubectl delete -f yamls/blue-deployment.yaml --ignore-not-found
kubectl delete -f yamls/green-deployment.yaml --ignore-not-found
kubectl delete service active-color-service --ignore-not-found
```

**Expected:** **Blue**, **green**, **and** **service** **removed**.

## Troubleshooting

- **No** **endpoints** **on** **Service** → **label** **selector** **must** **match** **both** **`app`** **and** **`version`**
- **Patch** **rejected** → **check** **JSON** **escaping** **in** **your** **shell** **or** **use** **`kubectl edit`**
- **Clients** **still** **see** **old** **version** → **DNS** **TTL**, **keep-alive**, **or** **caching** **outside** **Kubernetes**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/blue-deployment.yaml` | **v1** **Deployment** **`blue-app`** |
| `yamls/green-deployment.yaml` | **v2** **Deployment** **`green-app`** |
| `yamls/active-service.yaml` | **`active-color-service`** **front** **door** |

## Cleanup

```bash
kubectl delete -f yamls/blue-deployment.yaml --ignore-not-found 2>/dev/null || true
kubectl delete -f yamls/green-deployment.yaml --ignore-not-found 2>/dev/null || true
kubectl delete service active-color-service --ignore-not-found 2>/dev/null || true
```

## Next

[Track 5: Security and policy — Pod security standards](../../05-Security-and-Policy/01-pod-security-standards/README.md)
