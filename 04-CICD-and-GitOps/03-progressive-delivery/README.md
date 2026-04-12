# Progressive delivery — teaching transcript

## Intro

**A** **plain** **`Deployment`** **rolling** **update** **eventually** **replaces** **all** **Pods** **with** **the** **new** **template** **—** **if** **the** **new** **version** **is** **bad**, **you** **still** **commit** **full** **fleet** **risk** **unless** **you** **add** **gates** **outside** **the** **default** **controller**. **Progressive** **delivery** **(for** **example** **canary)** **shifts** **a** **small** **percentage** **of** **traffic** **to** **the** **new** **revision**, **pauses**, **and** **evaluates** **health** **before** **raising** **weight**. **Argo** **Rollouts** **implements** **`Rollout`** **resources** **that** **feel** **like** **`Deployment`** **YAML** **but** **carry** **`strategy.canary.steps`**. **The** **sample** **in** **`yamls/rollout.yaml`** **is** **read-first**; **`kubectl apply`** **requires** **the** **Argo** **Rollouts** **controller** **and** **CRDs**.

**Prerequisites:** [4.2 GitOps with Argo CD](../02-gitops-with-argocd/README.md); **[Track** **2](../../02-Core-Workloads/README.md)** **(Deployments)**; **Argo** **Rollouts** **installed** **for** **optional** **apply**.

## Flow of this lesson

```
  Rollout replaces Deployment for the workload shape
              │
              ▼
  canary.steps: setWeight → pause → setWeight → pause → …
              │
              ▼
  metrics / analysis (out of band) decide continue vs abort
```

**Say:**

**Read** **`setWeight: 20` then** **`pause: {duration: 10s}` as** **a** **script** **the** **controller** **executes** **—** **no** **magic**, **just** **state** **machine**.

## Learning objective

- **Contrast** **default** **`Deployment`** **rolling** **updates** **with** **canary-style** **progressive** **delivery**.
- **Interpret** **`yamls/rollout.yaml`** **(`steps`**, **`selector`**, **`template`)**.

## Why this matters

**Big-bang** **rollouts** **turn** **one** **bad** **commit** **into** **a** **company-wide** **outage** **—** **progressive** **delivery** **buys** **time** **to** **observe** **real** **traffic**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/04-CICD-and-GitOps/03-progressive-delivery" 2>/dev/null || cd .
```

## Step 1 — Inspect the Rollout spec

**What happens when you run this:**

You **study** **`argoproj.io/v1alpha1` `Rollout`** **with** **replica** **count**, **pod** **template**, **and** **canary** **steps**.

**Run:**

```bash
cat yamls/rollout.yaml
```

**Expected:** **`metadata.name: canary-demo`**, **`replicas: 5`**, **`strategy.canary.steps`** **with** **`setWeight`** **and** **`pause`**, **`selector`** **`app: rollout-demo`**.

---

## Step 2 — Optional CRD check

**What happens when you run this:**

**Confirms** **whether** **`kubectl apply`** **would** **succeed** **on** **this** **cluster**.

**Run:**

```bash
kubectl api-resources 2>/dev/null | grep -i rollout | head -n 10 || true
```

**Expected:** **`rollouts.argoproj.io`** **(or** **similar)** **when** **Rollouts** **is** **installed**.

---

## Step 3 — Optional apply (lab only)

**What happens when you run this:**

**Creates** **`canary-demo`** **Rollout** **in** **the** **current** **namespace** **—** **only** **if** **Step** **2** **showed** **the** **API**.

**Say:**

**Without** **Ingress** **or** **service** **mesh** **integration**, **traffic** **splitting** **may** **not** **do** **what** **students** **expect** **—** **call** **out** **that** **this** **YAML** **is** **the** **controller** **contract**, **not** **the** **whole** **prod** **topology**.

**Run:**

```bash
kubectl apply -f yamls/rollout.yaml
kubectl get rollout 2>/dev/null || kubectl get rollouts.argoproj.io 2>/dev/null || true
```

**Expected:** **Rollout** **object** **listed** **or** **apply** **error** **if** **CRD** **missing**.

## Video close — fast validation

**What happens when you run this:**

**Removes** **the** **sample** **Rollout** **if** **you** **applied** **it**.

**Run:**

```bash
kubectl delete -f yamls/rollout.yaml --ignore-not-found 2>/dev/null || true
```

**Expected:** **Resource** **gone** **or** **nothing** **to** **delete**.

## Troubleshooting

- **`no matches for kind "Rollout"`** → **install** **[Argo** **Rollouts](https://argo-rollouts.readthedocs.io/en/stable/installation/)**
- **Canary** **traffic** **unchanged** → **need** **Service**, **Ingress**, **or** **mesh** **integration** **per** **Rollouts** **docs**
- **Image** **pull** **errors** → **registry** **reachability** **or** **policy**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/rollout.yaml` | **Canary** **`Rollout`** **example** |

## Cleanup

```bash
kubectl delete -f yamls/rollout.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[4.4 Release strategies](../04-release-strategies/README.md)
