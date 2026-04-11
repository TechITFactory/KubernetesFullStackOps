# 3.1 Kustomize bases and overlays — teaching transcript

## Intro

**Kustomize** **composes** **Kubernetes** **YAML** **without** **embedding** **logic** **inside** **the** **base** **manifests**. **A** **`base`** **holds** **neutral** **Deployments** **and** **Services** **plus** **a** **`kustomization.yaml`** **that** **lists** **resources** **and** **shared** **labels**. **An** **`overlay`** **points** **at** **the** **base**, **adds** **`namePrefix`**, **`commonLabels`**, **and** **`patches`** **so** **production** **can** **scale** **replicas** **without** **duplicating** **the** **whole** **Deployment**. **`kubectl`** **ships** **with** **Kustomize** **(`kubectl apply -k`**, **`kubectl kustomize`)**.

**Prerequisites:** [Track 3 module](../README.md); [02-Core-Workloads](../../02-Core-Workloads/README.md) **(Deployments** **and** **Services)**.

## Flow of this lesson

```
  yamls/base (neutral manifests + kustomization.yaml)
              │
              ▼
  yamls/overlays/prod (resources: ../../base, patches, namePrefix)
              │
              ▼
  kubectl kustomize → rendered YAML → kubectl apply -k
```

**Say:**

**The** **base** **never** **says** **“production”**—**only** **the** **overlay** **injects** **`prod-`** **and** **`env: production`**.

## Learning objective

- **Structure** **a** **`base`** **and** **`prod`** **overlay** **using** **this** **repo’s** **`yamls/`** **tree**.
- **Render** **with** **`kubectl kustomize`** **and** **apply** **with** **`kubectl apply -k`**, **then** **verify** **labels** **and** **replicas**.

## Why this matters

**Copy-pasting** **YAML** **per** **environment** **guarantees** **drift**—**Kustomize** **keeps** **one** **source** **of** **truth** **for** **app** **shape** **and** **small** **deltas** **per** **env**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/03-Packaging-and-Environments/01-kustomize-bases-overlays" 2>/dev/null || cd .
```

## Step 1 — Inspect the base

**What happens when you run this:**

You **read** **the** **neutral** **Deployment** **and** **how** **`kustomization.yaml`** **groups** **resources** **and** **adds** **`managed-by=kustomize`**.

**Say:**

**Nothing** **in** **the** **base** **fixes** **replica** **count** **for** **prod**—**that** **comes** **from** **the** **overlay** **patch**.

**Run:**

```bash
cat yamls/base/kustomization.yaml
cat yamls/base/deployment.yaml
cat yamls/base/service.yaml
```

**Expected:** **`web-app`** **Deployment** **with** **`replicas: 1`**, **Service**, **and** **`commonLabels.managed-by: kustomize`** **in** **the** **kustomization** **file**.

---

## Step 2 — Inspect the production overlay

**What happens when you run this:**

The **overlay** **references** **`../../base`**, **sets** **`namePrefix: prod-`**, **`env: production`**, **and** **a** **patch** **for** **three** **replicas**.

**Run:**

```bash
cat yamls/overlays/prod/kustomization.yaml
cat yamls/overlays/prod/replica-patch.yaml
```

**Expected:** **Patch** **targets** **`Deployment/web-app`** **with** **`replicas: 3`**.

---

## Step 3 — Render (dry run compile)

**What happens when you run this:**

**Kustomize** **merges** **base** **+** **overlay** **to** **stdout** **without** **mutating** **the** **cluster**.

**Say:**

**I** **scroll** **the** **rendered** **Deployment** **and** **confirm** **`metadata.name`** **is** **`prod-web-app`** **and** **`replicas: 3`**.

**Run:**

```bash
kubectl kustomize yamls/overlays/prod
```

**Expected:** **Full** **manifest** **list** **including** **`prod-web-app`** **Deployment** **with** **three** **replicas** **and** **`env: production`** **labels**.

---

## Step 4 — Apply to the cluster

**What happens when you run this:**

**The** **same** **build** **is** **sent** **to** **the** **API** **server** **as** **`apply`**.

**Run:**

```bash
kubectl apply -k yamls/overlays/prod
```

**Expected:** **Resources** **created** **or** **configured** **(Deployment**, **Service)**.

---

## Step 5 — Verify

**What happens when you run this:**

**Confirms** **name** **prefix**, **replica** **count**, **and** **labels**.

**Run:**

```bash
kubectl get deployments --show-labels
kubectl get pods -l env=production
```

**Expected:** **`prod-web-app`** **with** **3** **ready** **replicas** **(once** **images** **pull)**; **Pods** **labeled** **`env=production`**.

## Video close — fast validation

**What happens when you run this:**

**Deletes** **exactly** **what** **the** **overlay** **defines**, **using** **the** **same** **`-k`** **entrypoint**.

**Say:**

**Delete** **uses** **the** **same** **compilation** **as** **apply**—**no** **manual** **name** **hunting**.

**Run:**

```bash
kubectl delete -k yamls/overlays/prod
```

**Expected:** **Deployment** **and** **Service** **removed**.

## Troubleshooting

- **`unable to find one of 'kustomization.yaml'`** → **run** **commands** **from** **this** **lesson** **directory** **so** **relative** **paths** **resolve**
- **`no matches for Id Deployment.v1.apps/web-app`** **(patch)** → **patch** **`name`**, **`kind`**, **`apiVersion`** **must** **match** **the** **base** **resource** **before** **`namePrefix`**
- **Used** **`-f`** **instead** **of** **`-k`** → **`kubectl apply -k`** **is** **required** **for** **directories** **with** **`kustomization.yaml`**
- **`namePrefix` doubled** → **do** **not** **hard-code** **`prod-web-app`** **in** **patches**; **patch** **`web-app`** **only**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/base/kustomization.yaml` | Base **resources** **and** **labels** |
| `yamls/base/deployment.yaml` | **web-app** **Deployment** |
| `yamls/base/service.yaml` | **Service** **for** **web** **app** |
| `yamls/overlays/prod/kustomization.yaml` | **Prod** **overlay** |
| `yamls/overlays/prod/replica-patch.yaml` | **Replica** **patch** |

## Cleanup

```bash
kubectl delete -k yamls/overlays/prod --ignore-not-found 2>/dev/null || true
```

## Next

[3.2 Helm charting strategies](../02-helm-charting-strategies/README.md)
