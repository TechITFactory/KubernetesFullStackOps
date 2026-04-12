# Security enforcement — teaching transcript

## Intro

**Pen** **test** **findings** **often** **flag** **flat** **east-west** **networks**. **This** **lesson** **applies** **`redis-locked-down`** **in** **`capstone-prod`**: **only** **Pods** **labeled** **`app: frontend`** **may** **send** **TCP** **ingress** **to** **Pods** **`app: redis`** **on** **port** **`6379`**. **Your** **frontend** **Deployment** **already** **uses** **`app: frontend`** **;** **Redis** **uses** **`app: redis`** **—** **verify** **labels** **before** **you** **apply**.

**Prerequisites:** [7.2 CI/CD and GitOps flow](../02-cicd-gitops-flow/README.md); [5.3 Network policies](../../05-Security-and-Policy/03-network-policies/README.md); **CNI** **that** **enforces** **`NetworkPolicy`**.

## Flow of this lesson

```
  All Pods in capstone-prod (unchanged default allow unless CNI default-deny elsewhere)
              │
              ▼
  NetworkPolicy selects redis pods → ingress only from frontend on 6379
              │
              ▼
  Validate connectivity (optional: kubectl exec curl/redis-cli)
```

**Say:**

**If** **DNS** **to** **`kube-system` breaks** **after** **policy** **changes**, **you** **added** **a** **different** **policy** **than** **this** **file**. **This** **manifest** **only** **restricts** **ingress** **to** **Redis**.

## Learning objective

- **Apply** **`capstone-network-policy.yaml`** **and** **state** **which** **flows** **remain** **legal**.

## Why this matters

**Database** **breaches** **rarely** **start** **with** **the** **database** **—** **they** **start** **with** **a** **random** **Pod** **that** **could** **reach** **it**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/07-Capstone-Project/03-security-enforcement" 2>/dev/null || cd .
```

## Step 1 — Inspect the policy

**What happens when you run this:**

**Confirms** **`podSelector`**, **`ingress.from`**, **and** **`ports`**.

**Run:**

```bash
cat yamls/capstone-network-policy.yaml
```

**Expected:** **`NetworkPolicy`** **`redis-locked-down`** **in** **`capstone-prod`**.

---

## Step 2 — Apply

**What happens when you run this:**

**Enforces** **the** **rule** **in** **the** **capstone** **namespace**.

**Run:**

```bash
kubectl apply -f yamls/capstone-network-policy.yaml
kubectl get networkpolicy -n capstone-prod
```

**Expected:** **`redis-locked-down`** **listed**.

## Video close — fast validation

**What happens when you run this:**

**Deletes** **the** **policy**.

**Run:**

```bash
kubectl delete -f yamls/capstone-network-policy.yaml --ignore-not-found
```

**Expected:** **Policy** **removed**.

## Troubleshooting

- **Policy** **no-op** → **CNI** **does** **not** **enforce** **`NetworkPolicy`**
- **Legitimate** **traffic** **blocked** → **label** **selectors** **or** **port** **numbers** **do** **not** **match** **workloads**
- **Namespace** **missing** → **complete** **[7.1](../01-deploy-enterprise-app/README.md)** **first**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/capstone-network-policy.yaml` | **Redis** **ingress** **lockdown** |

## Cleanup

```bash
kubectl delete -f yamls/capstone-network-policy.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[7.4 Observability and scaling](../04-observability-verification/README.md)
