# Track 7: Capstone project — teaching transcript

## Intro

**This** **capstone** **strings** **together** **skills** **from** **Tracks** **1–6:** **deploy** **a** **small** **multi-tier** **app** **in** **`capstone-prod`**, **wire** **GitOps** **(Argo** **CD** **`Application`)**, **lock** **east-west** **traffic** **with** **a** **`NetworkPolicy`**, **add** **an** **HPA** **for** **the** **frontend**, **and** **run** **a** **scripted** **“chaos”** **exercise** **that** **removes** **a** **`Service`** **so** **you** **restore** **it** **from** **the** **original** **manifests**. **Treat** **the** **namespace** **as** **disposable** **lab** **state** **—** **not** **a** **production** **tenant**.

**Prerequisites:** [Track 6: Observability and reliability](../06-Observability-and-Reliability/README.md); [Track 5: Security and policy](../05-Security-and-Policy/README.md); [Track 4: CI/CD and GitOps](../04-CICD-and-GitOps/README.md); [Track 3: Packaging and environments](../03-Packaging-and-Environments/README.md).

## Flow of this lesson

```
  7.1 Deploy Redis + frontend into capstone-prod
              │
              ▼
  7.2 Argo CD Application targets capstone-prod
              │
              ▼
  7.3 NetworkPolicy: only frontend → redis:6379
              │
              ▼
  7.4 HPA on capstone-frontend (2–8 replicas, 70% CPU)
              │
              ▼
  7.5 Chaos script + triage + re-apply redis backend
```

**Say:**

**I** **timebox** **the** **capstone** **defense** **like** **a** **real** **incident** **—** **fifteen** **minutes** **to** **green** **`kubectl get endpoints`**.

## Learning objective

- **Stand** **up** **the** **reference** **architecture** **and** **verify** **it** **with** **`kubectl get all`** **in** **`capstone-prod`**.
- **Execute** **the** **chaos** **and** **recovery** **path** **without** **hand-editing** **live** **objects** **blindly**.

## Why this matters

**Interviewers** **and** **on-call** **rotations** **both** **reward** **people** **who** **can** **move** **from** **symptom** **to** **fix** **with** **a** **repeatable** **toolchain**.

## Children (suggested order)

1. [7.1 Deploy enterprise application](01-deploy-enterprise-app/README.md)
2. [7.2 CI/CD and GitOps flow](02-cicd-gitops-flow/README.md)
3. [7.3 Security enforcement](03-security-enforcement/README.md)
4. [7.4 Observability and scaling](04-observability-verification/README.md)
5. [7.5 The final defense](05-final-defense/README.md)

## Module wrap — quick validation

**What happens when you run this:** **Confirm** **context** **and** **that** **the** **capstone** **namespace** **is** **empty** **before** **you** **start** **fresh**.

**Say:**

**I** **delete** **`capstone-prod`** **between** **takes** **so** **no** **student** **inherits** **my** **half-finished** **policies**.

```bash
kubectl config current-context
kubectl get ns capstone-prod 2>/dev/null || echo "capstone-prod not present (ok to start)"
```

## Troubleshooting

- **Argo** **CD** **not** **installed** → **skip** **7.2** **`apply`** **or** **install** **Argo** **first**
- **NetworkPolicy** **breaks** **DNS** **or** **egress** → **extend** **policy** **set** **(this** **lab** **only** **touches** **redis** **ingress)**
- **HPA** **`unknown`** → **metrics-server** **required**

## Next

[Course overview and further tracks](../../README.md)
