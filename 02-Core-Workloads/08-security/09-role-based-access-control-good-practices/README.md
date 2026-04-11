# 2.8.9 Role Based Access Control Good Practices — teaching transcript

## Intro

**RBAC** maps **subjects** (Users, Groups, **ServiceAccounts**) to **Roles** or **ClusterRoles** via bindings. **Good practices**: default **deny**, **namespace-scoped** **Roles** where possible, **avoid** **`cluster-admin`** for daily use, use **aggregate** **ClusterRoles** carefully, separate **CI** **ServiceAccounts** per repo, audit **`escalate`** and **`bind`** permissions (they can **grant** more power), and **document** **break-glass** **ClusterRoleBindings** with **expiry** or **ticket** IDs. **`kubectl auth can-i`** and **audit logs** validate reality.

**Prerequisites:** [2.8.8 Controlling Access to the Kubernetes API](../08-controlling-access-to-the-kubernetes-api/README.md).

## Flow of this lesson

```
  Principle of least privilege
              │
              ▼
  Role (namespace) vs ClusterRole (global)
              │
              ▼
  Bindings + audit for escalate/bind/cluster-admin
```

**Say:**

I grep **`cluster-admin`** **bindings** in **terraform** and **live** cluster during **quarterly** reviews.

## Learning objective

- Recommend **namespace** **Roles** vs **ClusterRoles** for typical app teams.
- Flag **dangerous** verbs (**escalate**, **bind**, **impersonate**) and **`cluster-admin`** sprawl.

## Why this matters

**RBAC** drift is **cumulative**—GitOps without **periodic** **live** diff hides **shadow** **admins**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/08-security/09-role-based-access-control-good-practices" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

RBAC good-practices notes.

**Run:**

```bash
kubectl apply -f yamls/2-8-9-role-based-access-control-good-practices-notes.yaml
kubectl get cm -n kube-system 2-8-9-role-based-access-control-good-practices-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-8-9-role-based-access-control-good-practices-notes` when allowed.

---

## Step 2 — Sample ClusterRoleBindings (read-only)

**What happens when you run this:**

Surface **cluster-admin** bindings—**do not** paste **secrets** from **describe**.

**Run:**

```bash
kubectl get clusterrolebinding 2>/dev/null | head -n 25 || true
kubectl get clusterrolebinding -o jsonpath='{range .items[?(@.roleRef.name=="cluster-admin")]}{.metadata.name}{"\t"}{.subjects}{"\n"}{end}' 2>/dev/null | head -n 15 || true
```

**Expected:** Binding names and subject snippets.

## Video close — fast validation

```bash
kubectl explain role.rules 2>/dev/null | head -n 35 || true
```

## Troubleshooting

- **Too many bindings** → export to **git** and **reduce** with **Hierarchical** **namespaces** / **RBAC** **managers**
- **CI uses cluster-admin** → scope **token** to **namespace** + **Role**
- **Helm Tiller** legacy → remove **cluster** **superuser** patterns
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-8-9-role-based-access-control-good-practices-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-8-9-role-based-access-control-good-practices-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.8.10 Good Practices for Kubernetes Secrets](../10-good-practices-for-kubernetes-secrets/README.md)
