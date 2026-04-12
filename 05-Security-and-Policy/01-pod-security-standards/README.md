# Pod security standards — teaching transcript

## Intro

**Pod** **Security** **Standards** **(PSS)** **define** **three** **profiles** **(`privileged`**, **`baseline`**, **`restricted`)** **that** **encode** **Linux** **hardening** **expectations**. **Pod** **Security** **Admission** **(PSA)** **reads** **namespace** **labels** **such** **as** **`pod-security.kubernetes.io/enforce: restricted`** **and** **rejects** **Pods** **that** **violate** **the** **profile** **at** **admission** **time**. **This** **lesson** **creates** **`hardened-env`**, **attempts** **a** **privileged** **Pod**, **then** **applies** **a** **restricted-compliant** **Pod**.

**Prerequisites:** [Track 5 module](../README.md); [Track 2 workloads](../../02-Core-Workloads/README.md) **(Pod** **spec** **basics)**.

## Flow of this lesson

```
  Namespace with enforce=restricted
              │
              ▼
  kubectl apply bad-pod → Forbidden (PSS)
              │
              ▼
  kubectl apply good-pod → Accepted
```

**Say:**

**The** **error** **message** **names** **`PodSecurity`** **and** **`restricted:latest`** **—** **that** **string** **is** **what** **you** **paste** **into** **runbooks**.

## Learning objective

- **Apply** **`secure-namespace.yaml`** **and** **interpret** **PSS** **labels** **on** **a** **namespace**.
- **Contrast** **rejected** **vs** **accepted** **Pod** **specs** **using** **live** **`kubectl apply`**.

## Why this matters

**One** **privileged** **Pod** **on** **a** **shared** **node** **is** **a** **lateral** **movement** **stepping** **stone** **—** **PSS** **turns** **that** **class** **of** **mistake** **into** **an** **immediate** **API** **denial**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/05-Security-and-Policy/01-pod-security-standards" 2>/dev/null || cd .
```

## Step 1 — Create the hardened namespace

**What happens when you run this:**

**Creates** **`hardened-env`** **with** **`pod-security.kubernetes.io/enforce: restricted`** **and** **`enforce-version: latest`**.

**Run:**

```bash
kubectl apply -f yamls/secure-namespace.yaml
kubectl get ns hardened-env --show-labels
```

**Expected:** **Namespace** **exists** **with** **PSS** **labels** **visible**.

---

## Step 2 — Attempt a non-compliant Pod

**What happens when you run this:**

**Applies** **`highly-dangerous-pod`** **with** **`privileged: true`** **and** **root** **context** **—** **the** **API** **should** **reject** **it**.

**Say:**

**Read** **the** **`Forbidden`** **body** **out** **loud** **—** **it** **lists** **which** **PSS** **checks** **failed**.

**Run:**

```bash
kubectl apply -f yamls/bad-pod.yaml
```

**Expected:** **Error** **similar** **to** **`violates PodSecurity "restricted:latest"`** **(wording** **depends** **on** **cluster** **version)**.

---

## Step 3 — Apply a compliant Pod

**What happens when you run this:**

**Applies** **`compliant-pod`** **with** **`runAsNonRoot`**, **`seccompProfile: RuntimeDefault`**, **dropped** **capabilities**, **and** **a** **non-root** **image**.

**Run:**

```bash
kubectl apply -f yamls/good-pod.yaml
kubectl get pods -n hardened-env -o wide
```

**Expected:** **`compliant-pod`** **reaches** **`Running`** **(after** **image** **pull)**.

## Video close — fast validation

**What happens when you run this:**

**Deletes** **the** **namespace** **and** **all** **Pods** **inside** **it**.

**Run:**

```bash
kubectl delete namespace hardened-env --ignore-not-found
```

**Expected:** **Namespace** **terminates**.

## Troubleshooting

- **Bad** **Pod** **accepted** → **PSA** **not** **enabled**, **wrong** **label**, **or** **exempt** **namespace** **configuration**
- **Good** **Pod** **rejected** → **image** **pull**, **seccomp** **profile** **not** **supported** **on** **node**, **or** **stricter** **policy** **overlay**
- **Version** **skew** → **check** **`enforce-version`** **against** **cluster** **docs**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/secure-namespace.yaml` | **`hardened-env`** **+** **PSS** **enforce** **labels** |
| `yamls/bad-pod.yaml` | **Privileged** **Pod** **(should** **fail)** |
| `yamls/good-pod.yaml` | **Restricted-friendly** **Pod** |

## Cleanup

```bash
kubectl delete namespace hardened-env --ignore-not-found 2>/dev/null || true
```

## Next

[5.2 RBAC design patterns](../02-rbac-design-patterns/README.md)
