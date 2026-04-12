# Helm charting strategies — teaching transcript

## Intro

**Helm** **packages** **Kubernetes** **apps** **into** **charts**: **`Chart.yaml`** **(metadata)**, **`values.yaml`** **(defaults)**, **and** **`templates/`** **(Go** **templates)**. **A** **release** **is** **a** **named** **installation** **of** **a** **chart** **in** **a** **namespace** **with** **revision** **history** **for** **upgrades** **and** **rollbacks**. **`helm template`** **prints** **rendered** **YAML** **without** **touching** **the** **cluster**—**same** **discipline** **as** **`kubectl kustomize`**.

**Prerequisites:** [3.1 Kustomize bases and overlays](../01-kustomize-bases-overlays/README.md); **Helm** **v3** **CLI**; [Track 3 module](../README.md).

## Flow of this lesson

```
  Chart (Chart.yaml, values.yaml, templates/)
              │
              ▼
  helm template / helm install merges values → manifests
              │
              ▼
  Kubernetes API + Helm release metadata (Secrets by default)
```

**Say:**

**Values** **are** **the** **API** **your** **CI** **pipeline** **and** **operators** **talk** **to**; **templates** **stay** **stable**.

## Learning objective

- **Navigate** **`yamls/simple-app`** **and** **explain** **how** **`{{ .Values.* }}`** **maps** **to** **`values.yaml`**.
- **Render** **with** **`helm template`** **and** **install** **with** **`helm install`**, **then** **verify** **with** **`helm ls`** **and** **`kubectl`**.

## Why this matters

**Fifty** **services** **without** **a** **package** **format** **means** **fifty** **snowflake** **directories** **and** **no** **shared** **upgrade** **story**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/03-Packaging-and-Environments/02-helm-charting-strategies" 2>/dev/null || cd .
```

## Step 1 — Inspect the chart

**What happens when you run this:**

You **see** **templated** **Deployment** **fields** **and** **default** **image** **`nginx:1.24`**.

**Run:**

```bash
cat yamls/simple-app/Chart.yaml
cat yamls/simple-app/values.yaml
cat yamls/simple-app/templates/deployment.yaml
```

**Expected:** **`replicaCount: 1`**, **image** **repository/tag**, **templates** **using** **`include "simple-app.fullname"`** **and** **`.Values`**.

---

## Step 2 — Render without installing

**What happens when you run this:**

**Helm** **evaluates** **templates** **and** **prints** **YAML** **to** **stdout**.

**Say:**

**If** **this** **output** **looks** **wrong**, **fix** **the** **chart** **before** **any** **`install`**.

**Run:**

```bash
helm template dry-run-check yamls/simple-app
```

**Expected:** **Valid** **Kubernetes** **manifests** **including** **at** **least** **the** **Deployment** **from** **`templates/`**.

---

## Step 3 — Install a release

**What happens when you run this:**

**Helm** **creates** **objects** **and** **stores** **release** **revision** **1**.

**Run:**

```bash
helm install my-first-release yamls/simple-app
```

**Expected:** **Release** **deployed**; **Pods** **become** **Running** **after** **pull**.

---

## Step 4 — Verify release and workloads

**What happens when you run this:**

**Cross-check** **Helm’s** **view** **with** **the** **API** **objects**.

**Run:**

```bash
helm ls
kubectl get pods --show-labels
kubectl get deploy
```

**Expected:** **`my-first-release`** **revision** **1**; **Pods** **with** **chart** **labels** **such** **as** **`app.kubernetes.io/name`**.

## Video close — fast validation

**What happens when you run this:**

**Removes** **the** **release** **and** **its** **managed** **resources** **(typical** **default** **behavior** **for** **this** **chart)**.

**Run:**

```bash
helm uninstall my-first-release
```

**Expected:** **Release** **gone** **from** **`helm ls`**.

## Troubleshooting

- **`cannot re-use a name that is still in use`** → **`helm uninstall my-first-release`** **or** **use** **`helm upgrade --install`**
- **`parse error` in template** → **check** **whitespace** **and** **`{{ }}`** **syntax** **in** **`templates/`**
- **`helm: command not found`** → **install** **Helm** **v3**
- **Wrong** **namespace** → **add** **`-n`** **to** **every** **`helm`** **and** **matching** **`kubectl`** **command**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/simple-app/Chart.yaml` | Chart **metadata** |
| `yamls/simple-app/values.yaml` | **Default** **values** |
| `yamls/simple-app/templates/deployment.yaml` | **Templated** **Deployment** |
| `yamls/simple-app/templates/_helpers.tpl` | **Naming** **helpers** |

## Cleanup

```bash
helm uninstall my-first-release 2>/dev/null || true
```

## Next

[3.3 Environment separation](../03-environment-separation/README.md)
