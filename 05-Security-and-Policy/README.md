# Track 5: Security and policy — teaching transcript

## Intro

**Security** **on** **Kubernetes** **layers** **Pod** **hardening** **(Pod** **Security** **labels)**, **identity** **and** **authorization** **(RBAC)**, **network** **zero-trust** **(NetworkPolicy)**, **admission-time** **policy** **(Kyverno** **or** **webhooks)**, **and** **supply-chain** **controls** **(image** **signing**, **SBOMs)**. **This** **track** **uses** **small** **manifests** **under** **each** **lesson’s** **`yamls/`** **folder** **so** **you** **can** **`kubectl apply`** **in** **a** **lab** **cluster** **and** **see** **deny/allow** **behavior** **at** **the** **API**.

**Prerequisites:** [Track 4: CI/CD and GitOps](../04-CICD-and-GitOps/README.md); [Track 2: Core workloads](../02-Core-Workloads/README.md) **(especially** **[2.8** **Security](../02-Core-Workloads/08-security/README.md)** **if** **you** **want** **deeper** **PSS** **and** **PSA** **theory)**.

## Flow of this lesson

```
  5.1 Pod Security Standards (namespace enforce + good/bad Pods)
              │
              ▼
  5.2 RBAC patterns (Role + RoleBinding + auth can-i)
              │
              ▼
  5.3 NetworkPolicies (default deny + targeted allow)
              │
              ▼
  5.4 Admission policy (Kyverno ClusterPolicy example)
              │
              ▼
  5.5 Image signing / SBOM (verification Job pattern)
```

**Say:**

**I** **never** **run** **`kubectl apply` on** **a** **ClusterPolicy** **in** **production** **without** **a** **dry-run** **pipeline** **—** **admission** **mistakes** **brick** **every** **`apply`**.

## Learning objective

- **Apply** **PSS-labeled** **namespaces** **and** **predict** **which** **Pods** **the** **API** **rejects**.
- **Use** **`kubectl auth can-i`** **with** **`--as=system:serviceaccount:...`** **to** **validate** **least-privilege** **RBAC**.
- **Read** **NetworkPolicy** **and** **Kyverno** **YAML** **enough** **to** **explain** **default** **deny** **and** **label** **gates**.

## Why this matters

**Compliance** **and** **incidents** **both** **ask** **“what** **could** **this** **identity** **do?”** **and** **“what** **could** **reach** **this** **database?”** **—** **these** **lessons** **name** **the** **objects** **that** **answer** **those** **questions**.

## Children (suggested order)

1. [5.1 Pod security standards](01-pod-security-standards/README.md)
2. [5.2 RBAC design patterns](02-rbac-design-patterns/README.md)
3. [5.3 Network policies](03-network-policies/README.md)
4. [5.4 Admission controls](04-admission-controls/README.md)
5. [5.5 Image signing and SBOMs](05-image-signing-sbom/README.md)

## Module wrap — quick validation

**What happens when you run this:** **Read-only** **glimpse** **of** **whether** **your** **context** **can** **see** **RBAC** **and** **policy** **APIs**.

**Say:**

**Before** **5.3**, **I** **confirm** **which** **CNI** **implements** **`NetworkPolicy`** **—** **otherwise** **the** **YAML** **“works”** **but** **does** **nothing**.

```bash
kubectl auth can-i list networkpolicies 2>/dev/null || true
kubectl api-resources 2>/dev/null | grep -i kyverno | head -n 8 || true
```

## Troubleshooting

- **`Forbidden` on** **PSS** **or** **policies** → **cluster** **version** **or** **managed** **policy** **overrides**
- **NetworkPolicy** **no-op** → **CNI** **does** **not** **enforce** **(check** **vendor** **matrix)**
- **Kyverno** **CRD** **missing** → **install** **[Kyverno](https://kyverno.io/docs/installation/)** **before** **applying** **5.4** **samples**

## Next

[Track 6: Observability and reliability](../06-Observability-and-Reliability/README.md)
