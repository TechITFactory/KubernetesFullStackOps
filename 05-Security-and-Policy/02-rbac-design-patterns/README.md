# RBAC design patterns — teaching transcript

## Intro

**RBAC** **binds** **Subjects** **(Users**, **Groups**, **or** **ServiceAccounts)** **to** **Roles** **or** **ClusterRoles** **via** **RoleBindings** **or** **ClusterRoleBindings**. **This** **lesson** **creates** **`junior-dev`** **ServiceAccount** **in** **`default`**, **a** **`pod-reader`** **Role** **limited** **to** **`get/list/watch`** **on** **`pods`** **and** **`pods/log`**, **and** **a** **`RoleBinding`**. **You** **verify** **behavior** **with** **`kubectl auth can-i`** **impersonating** **the** **ServiceAccount**.

**Prerequisites:** [5.1 Pod security standards](../01-pod-security-standards/README.md); [Track 2: Core workloads](../../02-Core-Workloads/README.md) **(RBAC** **overview** **optional)**.

## Flow of this lesson

```
  ServiceAccount junior-dev
              │
              ▼
  Role pod-reader (pods, pods/log read-only)
              │
              ▼
  RoleBinding → auth can-i --as=system:serviceaccount:default:junior-dev
```

**Say:**

**`cluster-admin` is** **not** **a** **career** **goal** **—** **tight** **Roles** **plus** **`can-i` tests** **are**.

## Learning objective

- **Apply** **Role**, **RoleBinding**, **and** **ServiceAccount** **YAML** **in** **the** **correct** **order**.
- **Use** **`kubectl auth can-i`** **with** **`--as`** **to** **prove** **allow** **and** **deny** **paths**.

## Why this matters

**Over-broad** **RBAC** **lets** **compromised** **CI** **tokens** **or** **compromised** **developer** **kubeconfigs** **exfiltrate** **secrets** **and** **delete** **data**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/05-Security-and-Policy/02-rbac-design-patterns" 2>/dev/null || cd .
```

## Step 1 — Create the RBAC objects

**What happens when you run this:**

**Registers** **the** **ServiceAccount**, **Role**, **and** **RoleBinding** **in** **`default`**.

**Run:**

```bash
kubectl apply -f yamls/service-account.yaml
kubectl apply -f yamls/dev-role.yaml
kubectl apply -f yamls/dev-rolebinding.yaml
kubectl get role,rolebinding,sa -n default | grep -E 'junior-dev|pod-reader' || true
```

**Expected:** **`junior-dev`**, **`pod-reader`**, **`junior-dev-binding`** **present**.

---

## Step 2 — Test allowed verbs

**What happens when you run this:**

**Asks** **the** **API** **whether** **the** **ServiceAccount** **may** **list** **Pods**.

**Run:**

```bash
kubectl auth can-i list pods --as=system:serviceaccount:default:junior-dev
```

**Expected:** **`yes`**.

---

## Step 3 — Test denied verbs

**What happens when you run this:**

**Probes** **verbs** **outside** **the** **Role** **(delete** **Pods**, **read** **Secrets)**.

**Run:**

```bash
kubectl auth can-i delete pods --as=system:serviceaccount:default:junior-dev
kubectl auth can-i get secrets --as=system:serviceaccount:default:junior-dev
```

**Expected:** **`no`** **for** **both** **(or** **`no`** **for** **delete** **and** **secrets** **if** **Role** **excludes** **secrets)**.

## Video close — fast validation

**What happens when you run this:**

**Removes** **the** **lab** **RBAC** **objects** **from** **`default`**.

**Run:**

```bash
kubectl delete -f yamls/dev-rolebinding.yaml --ignore-not-found
kubectl delete -f yamls/dev-role.yaml --ignore-not-found
kubectl delete -f yamls/service-account.yaml --ignore-not-found
```

**Expected:** **Objects** **removed**.

## Troubleshooting

- **`yes` when** **you** **expected** **`no`** → **another** **binding** **grants** **the** **verb** **(use** **`auth can-i` with** **`--list` if** **permitted)**
- **`Forbidden` on** **`auth can-i`** → **your** **user** **cannot** **impersonate** **—** **use** **elevated** **read-only** **context** **or** **skip** **`--as`**
- **Wrong** **namespace** → **all** **YAML** **here** **targets** **`default`**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/service-account.yaml` | **`junior-dev`** **ServiceAccount** |
| `yamls/dev-role.yaml` | **`pod-reader`** **Role** |
| `yamls/dev-rolebinding.yaml` | **Binds** **SA** **to** **Role** |

## Cleanup

```bash
kubectl delete -f yamls/dev-rolebinding.yaml --ignore-not-found 2>/dev/null || true
kubectl delete -f yamls/dev-role.yaml --ignore-not-found 2>/dev/null || true
kubectl delete -f yamls/service-account.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[5.3 Network policies](../03-network-policies/README.md)
