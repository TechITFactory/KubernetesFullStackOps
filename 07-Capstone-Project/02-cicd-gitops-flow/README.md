# CI/CD and GitOps flow — teaching transcript

## Intro

**GitOps** **for** **this** **capstone** **means** **declaring** **an** **Argo** **CD** **`Application`** **that** **points** **at** **a** **public** **example** **repository** **path** **`helm-guestbook`** **and** **syncs** **into** **`capstone-prod`**. **In** **a** **real** **company**, **that** **`repoURL`** **would** **be** **your** **private** **Git** **server** **with** **the** **same** **manifests** **you** **validated** **in** **CI**. **Requires** **Argo** **CD** **installed** **(typically** **`argocd`** **namespace** **and** **CRDs)**.

**Prerequisites:** [7.1 Deploy enterprise application](../01-deploy-enterprise-app/README.md); [4.2 GitOps with Argo CD](../../04-CICD-and-GitOps/02-gitops-with-argocd/README.md).

## Flow of this lesson

```
  Application CR in argocd namespace
              │
              ▼
  Argo CD clones repo path → renders → applies to capstone-prod
              │
              ▼
  UI or CLI shows sync state vs Git HEAD
```

**Say:**

**This** **sample** **does** **not** **replace** **your** **7.1** **YAML** **automatically** **unless** **the** **guestbook** **chart** **content** **matches** **what** **you** **expect** **—** **treat** **it** **as** **a** **pattern** **demo**.

## Learning objective

- **Read** **`capstone-argocd-app.yaml`** **and** **explain** **`source`**, **`destination`**, **and** **`syncPolicy`**.

## Why this matters

**CTO** **pressure** **for** **GitOps** **is** **really** **pressure** **for** **reviewable** **changes** **and** **automated** **reconciliation** **—** **the** **`Application`** **is** **where** **that** **contract** **lives**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/07-Capstone-Project/02-cicd-gitops-flow" 2>/dev/null || cd .
```

## Step 1 — Inspect the Application manifest

**What happens when you run this:**

**Shows** **`capstone-prod-sync`**: **`repoURL`**, **`path: helm-guestbook`**, **`destination.namespace: capstone-prod`**, **`automated.prune: true`**.

**Run:**

```bash
cat yamls/capstone-argocd-app.yaml
```

**Expected:** **Fields** **match** **the** **file** **in** **the** **repo**.

---

## Step 2 — Optional apply

**What happens when you run this:**

**Registers** **the** **`Application`** **in** **`argocd`** **namespace**.

**Run:**

```bash
kubectl apply -f yamls/capstone-argocd-app.yaml
kubectl get application.argoproj.io -n argocd 2>/dev/null | head -n 10 || true
```

**Expected:** **`capstone-prod-sync`** **listed** **or** **CRD**/**RBAC** **error**.

## Video close — fast validation

**What happens when you run this:**

**Deletes** **the** **`Application`** **object** **(review** **Argo** **docs** **for** **prune** **behavior** **on** **managed** **resources)**.

**Run:**

```bash
kubectl delete -f yamls/capstone-argocd-app.yaml --ignore-not-found
```

**Expected:** **`Application`** **removed**.

## Troubleshooting

- **`mapping not found`** → **install** **Argo** **CD**
- **Sync** **OutOfSync** **forever** → **compare** **live** **vs** **desired** **in** **UI**; **check** **kustomize** **or** **helm** **overlays**
- **Wrong** **namespace** **for** **`Application` metadata** → **defaults** **to** **`argocd`** **unless** **your** **install** **uses** **another** **namespace**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/capstone-argocd-app.yaml` | **Argo** **CD** **`Application`** **for** **capstone** **sync** |

## Cleanup

```bash
kubectl delete -f yamls/capstone-argocd-app.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[7.3 Security enforcement](../03-security-enforcement/README.md)
