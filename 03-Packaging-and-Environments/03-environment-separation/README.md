# Environment separation — teaching transcript

## Intro

**Namespaces** **provide** **RBAC** **and** **object** **isolation** **boundaries** **inside** **one** **cluster**. **Pairing** **namespaces** **with** **different** **Helm** **values** **files** **lets** **you** **install** **the** **same** **chart** **twice** **with** **different** **replica** **counts**, **tags**, **and** **policies** **without** **forking** **the** **chart**. **This** **lesson** **uses** **`dev-env`** **and** **`prod-env`** **plus** **`values-dev.yaml`** **and** **`values-prod.yaml`** **against** **the** **chart** **from** **[3.2](../02-helm-charting-strategies/README.md)**.

**Prerequisites:** [3.2 Helm charting strategies](../02-helm-charting-strategies/README.md) **(chart** **path** **`../02-helm-charting-strategies/yamls/simple-app`)**; [Track 3 module](../README.md).

## Flow of this lesson

```
  namespaces.yaml → dev-env, prod-env
              │
              ▼
  helm install -n <ns> -f values-<env>.yaml (same chart path)
              │
              ▼
  kubectl get pods -n dev-env vs prod-env
```

**Say:**

**Namespace** **is** **not** **security** **by** **itself**—**RBAC** **and** **NetworkPolicy** **still** **matter**—**but** **it** **stops** **accidental** **`kubectl get all`** **in** **the** **wrong** **place**.

## Learning objective

- **Create** **isolated** **namespaces** **from** **repo** **YAML**.
- **Install** **two** **releases** **of** **the** **same** **chart** **with** **different** **`-f`** **values** **into** **different** **namespaces**.

## Why this matters

**Shared** **clusters** **without** **namespace** **discipline** **mix** **secrets**, **Service** **DNS** **names**, **and** **quota** **accounting**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/03-Packaging-and-Environments/03-environment-separation" 2>/dev/null || cd .
```

## Step 1 — Create namespaces

**What happens when you run this:**

**Declares** **`dev-env`** **and** **`prod-env`**.

**Run:**

```bash
kubectl apply -f yamls/namespaces.yaml
kubectl get ns dev-env prod-env
```

**Expected:** **Both** **namespaces** **exist**.

---

## Step 2 — Compare values files

**What happens when you run this:**

**Shows** **how** **dev** **and** **prod** **diverge** **(replicas**, **image**, **etc.)**.

**Run:**

```bash
cat yamls/values-dev.yaml
cat yamls/values-prod.yaml
```

**Expected:** **Different** **`replicaCount`** **and** **image** **settings** **per** **file**.

---

## Step 3 — Install the same chart into both namespaces

**What happens when you run this:**

**Two** **Helm** **releases** **named** **`core-app`** **in** **separate** **namespaces** **(Helm** **3** **scoping)**.

**Say:**

**The** **chart** **path** **points** **back** **to** **lesson** **3.2**—**no** **duplicate** **chart** **in** **this** **folder**.

**Run:**

```bash
helm install core-app ../02-helm-charting-strategies/yamls/simple-app -f yamls/values-dev.yaml -n dev-env
helm install core-app ../02-helm-charting-strategies/yamls/simple-app -f yamls/values-prod.yaml -n prod-env
```

**Expected:** **Two** **successful** **installs**; **Pods** **schedule** **in** **each** **namespace**.

---

## Step 4 — Verify isolation

**What happens when you run this:**

**Confirms** **replica** **counts** **and** **namespaces** **do** **not** **bleed**.

**Run:**

```bash
kubectl get pods -n dev-env -o wide
kubectl get pods -n prod-env -o wide
helm ls -n dev-env
helm ls -n prod-env
```

**Expected:** **`dev-env`:** **one** **Pod**, **image** **tag** **`1.24`**; **`prod-env`:** **three** **Pods**, **image** **tag** **`1.24-alpine`** **(per** **`values-*.yaml`)**.

## Video close — fast validation

**What happens when you run this:**

**Removes** **namespaces** **and** **all** **namespaced** **objects** **(including** **Helm** **release** **secrets)**.

**Say:**

**For** **production** **clusters**, **prefer** **`helm uninstall`** **per** **namespace** **first** **if** **you** **need** **clean** **Helm** **history** **before** **namespace** **deletion**—**here** **we** **tear** **down** **the** **whole** **lab** **sandwich**.

**Run:**

```bash
helm uninstall core-app -n dev-env 2>/dev/null || true
helm uninstall core-app -n prod-env 2>/dev/null || true
kubectl delete -f yamls/namespaces.yaml --ignore-not-found
```

**Expected:** **Releases** **removed**; **namespaces** **terminated**.

## Troubleshooting

- **`release name already exists`** → **uninstall** **or** **pick** **a** **new** **release** **name**
- **`namespaces "dev-env" not found`** → **apply** **`namespaces.yaml`** **first**
- **Chart** **path** **errors** → **run** **from** **this** **lesson** **directory** **so** **`../02-helm-charting-strategies/...`** **resolves**
- **Same** **defaults** **in** **both** **envs** → **confirm** **`-f`** **flag** **points** **at** **the** **intended** **values** **file**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/namespaces.yaml` | **`dev-env`**, **`prod-env`** |
| `yamls/values-dev.yaml` | **Dev** **Helm** **values** |
| `yamls/values-prod.yaml` | **Prod** **Helm** **values** |

## Cleanup

```bash
helm uninstall core-app -n dev-env 2>/dev/null || true
helm uninstall core-app -n prod-env 2>/dev/null || true
kubectl delete -f yamls/namespaces.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[3.4 Promotion and rollbacks](../04-promotion-and-rollbacks/README.md)
