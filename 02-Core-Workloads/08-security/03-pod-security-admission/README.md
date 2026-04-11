# 2.8.3 Pod Security Admission — teaching transcript

## Intro

**Pod Security Admission (PSA)** is the **built-in admission plugin** that enforces **Pod Security Standards** at **namespace** scope using labels **`pod-security.kubernetes.io/enforce`**, **`audit`**, and **`warn`** (values: **privileged**, **baseline**, **restricted**). **enforce** blocks violating Pods; **audit** logs violations; **warn** surfaces warnings without blocking. Version skew and **exemptions** (users, runtime classes) exist—read docs for your **Kubernetes** minor. PSA replaced the need for many clusters to run **PSP** ([2.8.5](../05-pod-security-policies/README.md)).

**Prerequisites:** [2.8.2 Pod Security Standards](../02-pod-security-standards/README.md).

## Flow of this lesson

```
  Namespace labels (enforce / audit / warn)
              │
              ▼
  API admission evaluates Pod spec vs PSS level
              │
              ▼
  Allow | Audit log | Warn | Deny create/update
```

**Say:**

I show **`kubectl apply`** of a **privileged** Pod into **restricted** namespace in a **lab** only—expect **Forbidden** from admission.

## Learning objective

- Read **PSA** labels on **namespaces** and explain **enforce** vs **audit** vs **warn**.
- Predict **admission** outcomes for a Pod spec against a labeled level.

## Why this matters

**enforce** mis-set blocks deploys; **warn**-only namespaces let **privileged** workloads slip—pick labels per environment.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/08-security/03-pod-security-admission" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

PSA teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-8-3-pod-security-admission-notes.yaml
kubectl get cm -n kube-system 2-8-3-pod-security-admission-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-8-3-pod-security-admission-notes` when allowed.

---

## Step 2 — List namespace PSA labels (read-only)

**What happens when you run this:**

**grep** filters **pod-security** label keys.

**Run:**

```bash
kubectl get ns --show-labels 2>/dev/null | grep -E 'pod-security\.kubernetes\.io|NAME' | head -n 25 || true
```

**Expected:** Namespaces with PSA labels on clusters that set them; possibly empty.

## Video close — fast validation

```bash
kubectl get ns -o custom-columns='NAME:.metadata.name,ENFORCE:.metadata.labels.pod-security\.kubernetes\.io/enforce' 2>/dev/null | head -n 20 || true
```

## Troubleshooting

- **No labels** → GKE/EKS/AKS may use **admission** configs differently—check vendor **PSS** integration
- **Pod denied, message unclear** → API **audit** log or **events** on namespace
- **Helm hooks** fail PSA → pre-upgrade **Jobs** need compliant **securityContext**
- **Version mismatch** → PSA behavior tightened across minors—read **release notes**
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-8-3-pod-security-admission-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-8-3-pod-security-admission-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.8.4 Service Accounts](../04-service-accounts/README.md)
