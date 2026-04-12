# Controlling Access to the Kubernetes API — teaching transcript

## Intro

**Access to the API server** combines **authentication** (who you are: **X.509 client cert**, **bearer token**, **OIDC**, **webhook token**, **service account token**) and **authorization** (what you may do: **RBAC** primary; **ABAC** legacy; **Node** authorizer for **kubelet**). **Admission** runs after authz and can **mutate** or **validate** requests. **`kubectl auth can-i`** answers “may **this user** **verb** **resource**?” for triage. **Anonymous** access and **insecure** **8080** **apiserver** binds should be **off** in production.

**Prerequisites:** [2.8.7 Security for Windows Nodes](../07-security-for-windows-nodes/README.md); [2.7.5 kubeconfig](../../07-configuration/05-organizing-cluster-access-using-kubeconfig-files/README.md).

## Flow of this lesson

```
  Request → Authentication → Authorization (RBAC) → Admission → etcd persist
```

**Say:**

I demo **`kubectl auth can-i create pods --namespace dev`** as **self-service** triage before opening a **ticket** to **security**.

## Learning objective

- Order **authn**, **authz**, and **admission** in the request path.
- Use **`kubectl auth can-i`** for permission checks.
- Run the repo **inspect** script and extend with **`can-i`** examples.

## Why this matters

**Over-broad ClusterRoleBindings** are the fastest path from **compromised laptop** to **data exfiltration**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/08-security/08-controlling-access-to-the-kubernetes-api" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

API access teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-8-8-controlling-access-to-the-kubernetes-api-notes.yaml
kubectl get cm -n kube-system 2-8-8-controlling-access-to-the-kubernetes-api-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-8-8-controlling-access-to-the-kubernetes-api-notes` when allowed.

---

## Step 2 — Run inspect script

**What happens when you run this:**

**`kubectl get ns`** baseline from repo.

**Run:**

```bash
bash scripts/inspect-2-8-8-controlling-access-to-the-kubernetes-api.sh
```

**Expected:** Namespace list; exit 0.

---

## Step 3 — Self-check permissions (read-only)

**What happens when you run this:**

**`can-i`** for common verbs—results depend on your **kubeconfig** user.

**Run:**

```bash
kubectl auth can-i list pods --all-namespaces 2>/dev/null || true
kubectl auth can-i create clusterrolebindings 2>/dev/null || true
kubectl auth can-i --list 2>/dev/null | head -n 20 || true
```

**Expected:** **yes** / **no** / **Forbidden** on `--list` if not allowed.

## Video close — fast validation

```bash
kubectl config view --minify -o jsonpath='{.users[0].name}{"\n"}' 2>/dev/null || true
kubectl cluster-info 2>/dev/null || true
```

## Troubleshooting

- **`can-i` always yes** → you are using **cluster-admin**—switch to **least-privilege** user for realistic checks
- **OIDC token expired** → refresh **exec** plugin credentials
- **Webhook auth down** → **API** **503** on all requests—restore **IdP**
- **Impersonation** → **`--as`** / **`--as-group`** for **admin** debugging only
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-2-8-8-controlling-access-to-the-kubernetes-api.sh` | `kubectl get ns` |
| `yamls/2-8-8-controlling-access-to-the-kubernetes-api-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-8-8-controlling-access-to-the-kubernetes-api-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.8.9 Role Based Access Control Good Practices](../09-role-based-access-control-good-practices/README.md)
