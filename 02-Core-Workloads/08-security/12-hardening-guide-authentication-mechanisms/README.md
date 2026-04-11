# 2.8.12 Hardening Guide — Authentication Mechanisms — teaching transcript

## Intro

**API server authentication** options include **client certificates**, **static token files** (discouraged), **bootstrap tokens**, **ServiceAccount** tokens, **OIDC** integration, **webhook** token review, and **cloud IAM** authenticators. **Hardening** means: disable **anonymous** auth, prefer **short-lived** **OIDC** tokens, **rotate** **signing** keys, **restrict** **bootstrap** **token** usage to **node** **join** only, and **audit** **failed** **authentication** **attempts**. **kubeconfig** **exec** plugins should **not** **log** **tokens**.

**Prerequisites:** [2.8.11 Multi-tenancy](../11-multi-tenancy/README.md).

## Flow of this lesson

```
  User / robot → authenticator plugin → apiserver
                      │
                      ▼
              Identity → then RBAC (separate lesson path)
```

**Say:**

**OIDC** **groups** **claim** **mapping** to **RBAC** **ClusterRoleBindings** is where **enterprise** **join** **fails**—debug **JWT** **claims**.

## Learning objective

- Name common **Kubernetes** **API** **authentication** mechanisms.
- State **hardening** themes: **no** **anonymous**, **short-lived** tokens, **minimal** **static** secrets.

## Why this matters

**Long-lived** **admin** **kubeconfig** on **CI** **servers** is **credential** **theft** **waiting** to happen.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/08-security/12-hardening-guide-authentication-mechanisms" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Authentication hardening notes.

**Run:**

```bash
kubectl apply -f yamls/2-8-12-hardening-guide-authentication-mechanisms-notes.yaml
kubectl get cm -n kube-system 2-8-12-hardening-guide-authentication-mechanisms-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-8-12-hardening-guide-authentication-mechanisms-notes` when allowed.

---

## Step 2 — View API server flags indirectly (read-only)

**What happens when you run this:**

**Pods** **command** line often **shows** **apiserver** **flags** on **self-hosted** **clusters**—**grep** **carefully** (**sensitive**).

**Say:**

On **managed** **K8s**, you **do not** **see** **flags**—use **cloud** **docs** **instead**.

**Run:**

```bash
kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath='{.items[0].spec.containers[0].command}' 2>/dev/null | tr ' ' '\n' | grep -E 'anonymous|oidc|token' | head -n 15 || true
```

**Expected:** Flag fragments or empty on managed/unsupported layouts.

## Video close — fast validation

```bash
kubectl config view --minify -o jsonpath='{.users[0].user.exec.command}{"\n"}' 2>/dev/null || echo "no exec user in minify view"
```

## Troubleshooting

- **OIDC clock skew** → **NTP** on **nodes** and **laptops**
- **Webhook auth** **latency** → **API** **timeouts** **cluster-wide**
- **Static password file** → **remove**—**no** **exceptions**
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-8-12-hardening-guide-authentication-mechanisms-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-8-12-hardening-guide-authentication-mechanisms-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.8.13 Hardening Guide — Scheduler Configuration](../13-hardening-guide-scheduler-configuration/README.md)
