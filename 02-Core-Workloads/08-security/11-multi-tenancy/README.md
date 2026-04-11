# 2.8.11 Multi-tenancy — teaching transcript

## Intro

**Multi-tenancy** on Kubernetes usually means **soft** isolation: **namespaces** (or **hierarchical** **namespaces**), **RBAC** **boundaries**, **ResourceQuota** / **LimitRange**, **NetworkPolicy** default **deny**, **Pod** **security** **labels**, **admission** **policies** (Kyverno, Gatekeeper), and **audit** **segregation** by **tenant**. **Hard** isolation (regulatory **separate** **clusters**) still exists—do not pretend **NetworkPolicy** alone is a **hypervisor**. **Fair scheduling** (**PriorityClass** discipline) prevents **noisy** **neighbor** **CPU** **starvation**.

**Prerequisites:** [2.8.10 Good Practices for Kubernetes Secrets](../10-good-practices-for-kubernetes-secrets/README.md); [NetworkPolicy](../../05-services-load-balancing-and-networking/06-network-policies/README.md).

## Flow of this lesson

```
  Tenant → namespace(s) + RBAC + quota + network policy + PSA
              │
              ▼
  Optional: cluster-per-tenant for hard isolation
```

**Say:**

I draw **three** **rings**: **same** **namespace** **(bad)**, **namespace** **per** **team**, **cluster** **per** **reg** **environment**.

## Learning objective

- Contrast **soft** vs **hard** **multi-tenancy** models on Kubernetes.
- Name **API** objects commonly combined for **tenant** isolation.

## Why this matters

**SOC2** **auditors** ask **where** **blast** **radius** **stops**—your **answer** should name **objects**, not **vibes**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/08-security/11-multi-tenancy" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Multi-tenancy teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-8-11-multi-tenancy-notes.yaml
kubectl get cm -n kube-system 2-8-11-multi-tenancy-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-8-11-multi-tenancy-notes` when allowed.

---

## Step 2 — Quota and network policy inventory (read-only)

**What happens when you run this:**

Shows whether **tenancy** **controls** exist beyond **RBAC**.

**Run:**

```bash
kubectl get resourcequota -A 2>/dev/null | head -n 15 || true
kubectl get networkpolicy -A 2>/dev/null | head -n 15 || true
```

**Expected:** Rows or empty on **open** clusters.

## Video close — fast validation

```bash
kubectl get ns --show-labels 2>/dev/null | head -n 15
```

## Troubleshooting

- **Quota blocks deploy** → **LimitRange** **defaults** **plus** **sum** **exceeds** **quota**
- **Cross-namespace** **DNS** → **NetworkPolicy** **egress** to **kube-dns**
- **Shared** **Prometheus** → **RBAC** **for** **metrics** **labels** **by** **tenant**
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-8-11-multi-tenancy-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-8-11-multi-tenancy-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.8.12 Hardening Guide — Authentication Mechanisms](../12-hardening-guide-authentication-mechanisms/README.md)
