# Custom resources — teaching transcript

## Intro

**CustomResourceDefinitions** **define** **new** **API** **kinds** **versioned** **under** **a** **group** **(for** **example** **`stable.example.com/v1`)**. **Users** **`kubectl apply`** **instances**; **controllers** **(often** **Go** **operators)** **watch** **and** **reconcile**. **Schema** **validation**, **defaulting**, **and** **conversion** **webhooks** **shape** **the** **developer** **experience**. **`kubectl explain`** **and** **`kubectl get <kind>`** **work** **once** **the** **CRD** **is** **installed**.

**Prerequisites:** [2.13.2 Extending the Kubernetes API](../04-extending-the-kubernetes-api/README.md).

## Flow of this lesson

```
  CRD YAML applied (cluster-admin)
              │
              ▼
  api-resources lists new KIND + SHORTNAMES
              │
              ▼
  Controllers reconcile custom objects
```

**Say:**

**I** **pick** **one** **boring** **CRD** **from** **`kubectl get crd`** **and** **`kubectl explain`** **it** **live**—**students** **see** **the** **whole** **loop**.

## Learning objective

- Run **repo** **inspect** **script** **filtering** **custom-related** **API** **resources**.
- Use **`kubectl explain`** **against** **an** **installed** **CRD** **kind**.

## Why this matters

**Every** **GitOps** **platform** **tool** **you** **install** **adds** **CRDs**—**understanding** **them** **is** **how** **you** **debug** **`kubectl apply` failures**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/13-extending-kubernetes/05-custom-resources" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-13-2-1-custom-resources-notes.yaml
kubectl get cm -n kube-system 2-13-2-1-custom-resources-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-13-2-1-custom-resources-notes`** when allowed.

---

## Step 2 — Custom API resources (read-only)

**What happens when you run this:**

**Script** **greps** **`api-resources`** **for** **`custom`**.

**Run:**

```bash
bash scripts/inspect-2-13-2-1-custom-resources.sh 2>/dev/null || true
kubectl get crd 2>/dev/null | head -n 15 || true
```

**Expected:** **Filtered** **`api-resources`** **lines**; **CRD** **names**.

## Video close — fast validation

```bash
PL="$(kubectl get crd -o jsonpath='{.items[0].spec.names.plural}' 2>/dev/null)"
G="$(kubectl get crd -o jsonpath='{.items[0].spec.group}' 2>/dev/null)"
if [ -n "$PL" ] && [ -n "$G" ]; then kubectl explain "$PL.$G" 2>/dev/null | head -n 18; fi || true
```

## Troubleshooting

- **Explain** **fails** → **CRD** **not** **installed** **or** **plural** **name** **required**
- **CRD** **upgrade** **breaks** **clients** → **conversion** **webhooks** **and** **version** **skew**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-13-2-1-custom-resources-notes.yaml` | Notes ConfigMap |
| `scripts/inspect-2-13-2-1-custom-resources.sh` | **`kubectl api-resources | grep -i custom`** |

## Cleanup

```bash
kubectl delete configmap 2-13-2-1-custom-resources-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.13.2.2 Kubernetes API aggregation layer](../06-kubernetes-api-aggregation-layer/README.md)
