# 2.8.2 Pod Security Standards — teaching transcript

## Intro

**Pod Security Standards (PSS)** define three **policy levels** for Pods: **privileged** (unrestricted), **baseline** (known dangerous defaults disallowed), and **restricted** (hardened, security-focused). They express **what** a Pod may do (host namespaces, **capabilities**, **volumes**, **runAsNonRoot**, **seccomp**, **seccompProfile**, etc.). **PSS** is **policy content**; enforcement is **Pod Security Admission** ([2.8.3](../03-pod-security-admission/README.md)) or legacy **PSP** ([2.8.5](../05-pod-security-policies/README.md)). Charts that request **privileged** fail **restricted** namespaces—by design.

**Prerequisites:** [2.8.1 Cloud Native Security](../01-cloud-native-security/README.md); Pods from [04-workloads](../../04-workloads/README.md).

## Flow of this lesson

```
  Pod spec fields (securityContext, volumes, …)
              │
              ▼
  Compared to PSS profile: privileged | baseline | restricted
              │
              ▼
  Enforced by PSA / other admission (next lessons)
```

**Say:**

I pull **`restricted`** from the official table and walk one **Helm** **values.yaml** that sets **capabilities**—viewers see concrete diffs.

## Learning objective

- Contrast **privileged**, **baseline**, and **restricted** PSS levels.
- Map common **Pod** fields (capabilities, **hostPath**, **hostNetwork**) to PSS expectations.

## Why this matters

**Compliance** frameworks map to **restricted**-like controls; without vocabulary, security and platform teams talk past each other.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/08-security/02-pod-security-standards" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

PSS teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-8-2-pod-security-standards-notes.yaml
kubectl get cm -n kube-system 2-8-2-pod-security-standards-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-8-2-pod-security-standards-notes` when allowed.

---

## Step 2 — Inspect a running Pod securityContext (read-only)

**What happens when you run this:**

Shows real **securityContext** usage for the **first** **kube-system** Pod (if any).

**Say:**

I avoid dumping **secrets**—only **`securityContext`** and **capabilities** if present.

**Run:**

```bash
P="$(kubectl get pods -n kube-system -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)"
if [ -n "$P" ]; then kubectl get pod "$P" -n kube-system -o jsonpath='{.spec.securityContext}{"\n"}{.spec.containers[0].securityContext}{"\n"}' 2>/dev/null; fi || true
```

**Expected:** JSON fragments or empty if fields unset / no pods.

## Video close — fast validation

```bash
kubectl explain pod.spec.securityContext 2>/dev/null | head -n 30 || true
```

## Troubleshooting

- **xargs empty** → pick a pod name manually with **`kubectl get pods -n kube-system`**
- **PSS vs SCC/PSP** → OpenShift and legacy PSP add another layer—name vendor differences
- **Charts need CAP_SYS_ADMIN** → document exception process; do not silently widen **namespace** policy
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-8-2-pod-security-standards-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-8-2-pod-security-standards-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.8.3 Pod Security Admission](../03-pod-security-admission/README.md)
