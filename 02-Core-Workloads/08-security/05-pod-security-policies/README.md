# 2.8.5 Pod Security Policies — teaching transcript

## Intro

**PodSecurityPolicy (PSP)** was a **cluster-level** admission mechanism **deprecated** and **removed** in modern Kubernetes (use **PSS + PSA** instead). You may still see **PSP** objects or **RBAC** references in **older** clusters and migration guides. This lesson is **historical awareness**: recognize **`policy/v1beta1` PodSecurityPolicy**, understand why **PSA** replaced it, and plan **migration** to **namespace labels** and **admission** that matches your cloud provider.

**Prerequisites:** [2.8.4 Service Accounts](../04-service-accounts/README.md); [2.8.3 PSA](../03-pod-security-admission/README.md).

## Flow of this lesson

```
  Legacy: PSP + RBAC use of PSP
              │
              ▼
  Modern: PSS + PSA (namespace labels)
```

**Say:**

If **`kubectl get psp`** still works, add **PSP removal** to the upgrade runbook before jumping minor versions.

## Learning objective

- Describe **PSP** as **deprecated/removed** and point to **PSS/PSA** replacement.
- Recognize **PSP** artifacts in **RBAC** during cluster archaeology.

## Why this matters

Skipping **PSP** migration breaks **upgrades**; teams confuse **PSP** with **PSS** acronyms in audits.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/08-security/05-pod-security-policies" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

PSP migration notes.

**Run:**

```bash
kubectl apply -f yamls/2-8-5-pod-security-policies-notes.yaml
kubectl get cm -n kube-system 2-8-5-pod-security-policies-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-8-5-pod-security-policies-notes` when allowed.

---

## Step 2 — Probe for PSP API (read-only)

**What happens when you run this:**

Returns rows only on **old** clusters.

**Run:**

```bash
kubectl api-resources | grep -i podsecuritypolicy || true
kubectl get psp 2>/dev/null | head -n 10 || true
```

**Expected:** Empty on current Kubernetes; PSP list on legacy only.

## Video close — fast validation

```bash
kubectl get ns --show-labels 2>/dev/null | grep pod-security | head -n 10 || true
```

## Troubleshooting

- **PSP blocks upgrade** → follow distro **PSP → PSA** guide before **control plane** bump
- **RBAC references `use` on psp** → remove bindings during migration
- **Vendor SCC** (OpenShift) → parallel concept—not PSP—use Red Hat docs
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-8-5-pod-security-policies-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-8-5-pod-security-policies-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.8.6 Security for Linux Nodes](../06-security-for-linux-nodes/README.md)
