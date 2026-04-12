# GitOps with Argo CD — teaching transcript

## Intro

**GitOps** **means** **the** **Git** **repository** **holds** **the** **desired** **cluster** **state** **and** **an** **agent** **inside** **the** **cluster** **(Argo** **CD)** **continuously** **reconciles** **live** **resources** **to** **match** **that** **repo**. **Manual** **`kubectl edit` on** **GitOps-managed** **workloads** **creates** **drift** **that** **automated** **`selfHeal`** **can** **revert** **—** **the** **approved** **change** **path** **is** **a** **merge** **request** **to** **Git**, **not** **a** **shell** **on** **production**. **This** **lesson** **centers** **on** **the** **`Application`** **custom** **resource** **in** **`yamls/application.yaml`**.

**Prerequisites:** [4.1 Pipeline design](../01-pipeline-design/README.md); **Argo** **CD** **installed** **(optional** **for** **`kubectl apply`)**; **[Track** **2](../../02-Core-Workloads/README.md)** **for** **Deployments** **and** **namespaces**.

## Flow of this lesson

```
  Git repo (path + revision) + cluster destination
              │
              ▼
  Argo CD Application spec (syncPolicy automated)
              │
              ▼
  Controller syncs namespace to match Git; self-heal reverses drift
```

**Say:**

**`syncPolicy.automated.selfHeal: true` is** **aggressive** **—** **great** **for** **labs**, **dangerous** **if** **you** **have** **not** **thought** **through** **blast** **radius** **and** **RBAC**.

## Learning objective

- **Explain** **Git**, **the** **`Application`** **spec** **(`source`**, **`destination`**, **`syncPolicy`)**, **and** **the** **idea** **of** **drift**.
- **Optionally** **apply** **the** **sample** **`Application`** **and** **observe** **sync** **behavior** **when** **Argo** **CD** **is** **present**.

## Why this matters

**If** **production** **state** **only** **lives** **in** **someone’s** **terminal** **history**, **you** **cannot** **audit**, **roll** **back**, **or** **disaster-recover** **with** **confidence**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/04-CICD-and-GitOps/02-gitops-with-argocd" 2>/dev/null || cd .
```

## Step 1 — Inspect the Argo CD Application

**What happens when you run this:**

You **read** **which** **Git** **repo**, **path**, **revision**, **and** **namespace** **Argo** **CD** **should** **manage**, **plus** **automation** **flags**.

**Say:**

**`destination.namespace: guestbook` plus** **`CreateNamespace=true` means** **Argo** **can** **create** **the** **target** **namespace** **if** **it** **is** **missing** **—** **confirm** **that** **matches** **your** **policy**.

**Run:**

```bash
cat yamls/application.yaml
```

**Expected:** **`kind: Application`**, **`repoURL`**, **`path: guestbook`**, **`syncPolicy.automated`**, **`prune`**, **`selfHeal`**, **`CreateNamespace=true`**.

---

## Step 2 — Verify Argo CD APIs (optional, read-only)

**What happens when you run this:**

**If** **the** **cluster** **has** **Argo** **CD**, **you** **see** **CRDs** **or** **`Application`** **objects** **in** **`argocd`** **namespace**.

**Run:**

```bash
kubectl get crd 2>/dev/null | grep -i argoproj.io | head -n 15 || true
kubectl get applications.argoproj.io -n argocd 2>/dev/null | head -n 10 || true
```

**Expected:** **CRD** **rows** **or** **forbidden** **/ ** **empty** **if** **Argo** **not** **installed**.

---

## Step 3 — Optional apply and drift experiment

**What happens when you run this:**

**Only** **if** **Argo** **CD** **is** **installed** **and** **you** **may** **mutate** **the** **cluster:** **apply** **the** **`Application`**, **wait** **for** **sync**, **then** **temporarily** **`kubectl scale`** **or** **`kubectl edit`** **a** **managed** **Deployment** **and** **watch** **self-heal** **revert** **it**.

**Say:**

**This** **experiment** **proves** **Git** **wins** **when** **`selfHeal`** **is** **on** **—** **document** **that** **for** **your** **runbook** **before** **turning** **it** **on** **in** **prod**.

**Run:**

```bash
kubectl apply -f yamls/application.yaml
```

**Expected:** **`Application`** **accepted** **or** **error** **(CRD** **missing**, **RBAC**, **etc.)**.

**Challenge** **(after** **sync** **succeeds):** **In** **`guestbook`**, **change** **a** **replica** **count** **with** **`kubectl`** **—** **observe** **Argo** **CD** **reverting** **to** **Git** **when** **`selfHeal`** **is** **enabled**.

## Video close — fast validation

**What happens when you run this:**

**If** **you** **applied** **in** **Step** **3**, **remove** **the** **`Application`** **object** **(does** **not** **always** **delete** **guestbook** **workloads** **depending** **on** **finalizers** **and** **prune** **—** **check** **Argo** **UI** **/ ** **docs)**.

**Run:**

```bash
kubectl delete -f yamls/application.yaml --ignore-not-found 2>/dev/null || true
```

**Expected:** **`demo-gitops-app`** **removed** **from** **`argocd`** **namespace** **when** **the** **command** **succeeds**.

## Troubleshooting

- **`error: resource mapping not found`** → **install** **Argo** **CD** **CRDs** **and** **controller**
- **`namespace argocd not found`** → **create** **namespace** **or** **install** **Argo** **CD** **manifests**
- **Sync** **stuck** **on** **private** **repo** → **credentials**, **SSH** **keys**, **or** **App** **Project** **RBAC**
- **Prune** **deleted** **unexpected** **objects** → **review** **`syncPolicy.prune`** **and** **resource** **annotations**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/application.yaml` | **Argo** **CD** **`Application`** **pointing** **at** **public** **example** **apps** **repo** |

## Cleanup

```bash
kubectl delete -f yamls/application.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[4.3 Progressive delivery](../03-progressive-delivery/README.md)
