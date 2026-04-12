# Admission controls — teaching transcript

## Intro

**After** **authentication** **and** **RBAC**, **admission** **controllers** **and** **webhooks** **can** **mutate** **or** **validate** **objects** **before** **they** **persist** **in** **etcd**. **Policy** **engines** **like** **[Kyverno](https://kyverno.io/)** **express** **rules** **as** **Kubernetes** **resources** **(for** **example** **`ClusterPolicy`)**. **The** **sample** **`require-labels-policy.yaml`** **requires** **every** **`Pod`** **to** **carry** **an** **`env`** **label**. **Do** **not** **`kubectl apply`** **it** **unless** **Kyverno** **is** **installed** **and** **you** **accept** **cluster-wide** **enforcement**.

**Prerequisites:** [5.3 Network policies](../03-network-policies/README.md); [4.2 GitOps with Argo CD](../../04-CICD-and-GitOps/02-gitops-with-argocd/README.md) **(admission** **and** **webhook** **context**, **optional)**.

## Flow of this lesson

```
  kubectl apply reaches API
              │
              ▼
  Mutating admission (optional) → Validating admission
              │
              ▼
  Kyverno ClusterPolicy pattern match → allow or reject
```

**Say:**

**RBAC** **answers** **“may** **this** **user** **create** **a** **Pod?”** **Admission** **answers** **“is** **this** **Pod** **allowed** **to** **exist** **even** **if** **RBAC** **says** **yes?”**

## Learning objective

- **Describe** **where** **admission** **fits** **in** **the** **API** **request** **path**.
- **Read** **`ClusterPolicy`** **YAML** **and** **predict** **which** **Pods** **would** **fail** **validation**.

## Why this matters

**Org** **rules** **(labels**, **image** **registries**, **resource** **limits)** **belong** **in** **admission** **—** **not** **in** **informal** **Slack** **reminders**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/05-Security-and-Policy/04-admission-controls" 2>/dev/null || cd .
```

## Step 1 — Inspect the Kyverno ClusterPolicy

**What happens when you run this:**

**You** **read** **`require-labels`**: **`validationFailureAction: Enforce`**, **rule** **matching** **`Pod`**, **pattern** **requiring** **`metadata.labels.env`**.

**Run:**

```bash
cat yamls/require-labels-policy.yaml
```

**Expected:** **`kind: ClusterPolicy`**, **`check-for-env-label`**, **`validate.pattern.metadata.labels.env`**.

---

## Step 2 — Optional cluster inventory

**What happens when you run this:**

**Checks** **whether** **Kyverno** **CRDs** **exist** **before** **any** **`apply`**.

**Run:**

```bash
kubectl api-resources 2>/dev/null | grep -i kyverno | head -n 15 || true
kubectl get clusterpolicy 2>/dev/null | head -n 10 || true
```

**Expected:** **API** **resources** **or** **empty** **if** **Kyverno** **not** **installed**.

---

## Step 3 — Optional apply (lab with Kyverno only)

**What happens when you run this:**

**Installs** **cluster-wide** **enforcement** **—** **skip** **unless** **you** **own** **the** **cluster**.

**Say:**

**After** **this** **exists**, **Pods** **without** **`env`** **labels** **fail** **everywhere** **the** **policy** **matches** **—** **coordinate** **with** **the** **team** **before** **turning** **on** **`Enforce`**.

**Run:**

```bash
kubectl apply -f yamls/require-labels-policy.yaml
```

**Expected:** **`clusterpolicy.kyverno.io/require-labels created`** **or** **error** **if** **CRD** **missing**.

## Video close — fast validation

**What happens when you run this:**

**Deletes** **the** **policy** **if** **you** **applied** **Step** **3**.

**Run:**

```bash
kubectl delete -f yamls/require-labels-policy.yaml --ignore-not-found
```

**Expected:** **Policy** **removed**.

## Troubleshooting

- **`resource mapping not found`** → **install** **Kyverno**
- **`Timeout`** **on** **admission** → **webhook** **latency** **or** **networkPolicy** **to** **Kyverno** **service**
- **False** **positives** **on** **system** **Pods** → **tune** **`match`** **blocks** **or** **use** **namespaced** **policies**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/require-labels-policy.yaml` | **Kyverno** **`ClusterPolicy`** **(requires** **`env`** **label** **on** **Pods)** |

## Cleanup

```bash
kubectl delete -f yamls/require-labels-policy.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[5.5 Image signing and SBOMs](../05-image-signing-sbom/README.md)
