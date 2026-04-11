# 2.8.4 Service Accounts — teaching transcript

## Intro

A **ServiceAccount** is an identity for **in-cluster** workloads. Each namespace has a **default** ServiceAccount; Pods use **`spec.serviceAccountName`** (or **default**). **Tokens** for API access are **mounted** into Pods (or obtained via **TokenRequest** API on supported versions). **`automountServiceAccountToken: false`** disables the default token mount when the workload should not call the API. **RBAC** binds **Roles**/**ClusterRoles** to **ServiceAccounts** via **RoleBinding**/**ClusterRoleBinding**—without bindings, the token has minimal rights. **imagePullSecrets** on ServiceAccount supply registry credentials to all Pods using that account.

**Prerequisites:** [2.8.3 Pod Security Admission](../03-pod-security-admission/README.md); [2.7.2 Secrets](../../07-configuration/02-secrets/README.md).

## Flow of this lesson

```
  ServiceAccount (namespace-scoped)
              │
              ├── token projection → Pod
              ├── RoleBinding → permissions
              └── imagePullSecrets → registry auth
```

**Say:**

**Default** ServiceAccount plus **cluster-admin** **ClusterRoleBinding** is a common **breach** pattern—tie identity to **least privilege**.

## Learning objective

- Explain **default** vs named **ServiceAccounts** and **automountServiceAccountToken**.
- List **ServiceAccounts** and relate them to **RoleBindings**.
- Run the repo **inspect** script and extend with **`kubectl get sa,rolebinding`**.

## Why this matters

Stolen **projected tokens** from overly powerful **ServiceAccounts** are lateral movement fuel.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/08-security/04-service-accounts" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

ServiceAccount teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-8-4-service-accounts-notes.yaml
kubectl get cm -n kube-system 2-8-4-service-accounts-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-8-4-service-accounts-notes` when allowed.

---

## Step 2 — Run inspect script

**What happens when you run this:**

Baseline **`kubectl get ns`** from repo script.

**Run:**

```bash
bash scripts/inspect-2-8-4-service-accounts.sh
```

**Expected:** Namespace list; exit 0.

---

## Step 3 — List ServiceAccounts and bindings (read-only)

**What happens when you run this:**

Correlates **sa** with **rolebinding** in **default** namespace sample.

**Run:**

```bash
kubectl get serviceaccounts -A 2>/dev/null | head -n 20 || true
kubectl get rolebindings,clusterrolebindings -A 2>/dev/null | head -n 25 || true
```

**Expected:** Tables; may be truncated on large clusters.

## Video close — fast validation

```bash
kubectl explain pod.spec.serviceAccountName 2>/dev/null | head -n 15 || true
kubectl get sa default -n default -o yaml 2>/dev/null | sed -n '1,35p' || true
```

## Troubleshooting

- **`system:serviceaccount:ns:name` in binding** → subject reference syntax for **RBAC**
- **Token not mounted** → **automountServiceAccountToken** false at Pod or SA level
- **403 from API inside Pod** → add **RoleBinding**—token exists but **RBAC** denies
- **Long-lived legacy tokens** → migrate to **bound** tokens / **TokenRequest** per version docs
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-2-8-4-service-accounts.sh` | Baseline `kubectl get ns` |
| `yamls/2-8-4-service-accounts-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-8-4-service-accounts-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.8.5 Pod Security Policies](../05-pod-security-policies/README.md)
