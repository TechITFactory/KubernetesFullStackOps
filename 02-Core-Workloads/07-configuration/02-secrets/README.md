# Secrets — teaching transcript

## Intro

**Secrets** store **sensitive** values (TLS keys, registry credentials, tokens) **base64-encoded** in the API (**not encryption** by itself). Pods mount Secrets as **files** or inject as **env vars** (env is often discouraged for secrets—visible in **`kubectl describe`** and process listings). **RBAC** restricts who reads Secrets; **encryption at rest** protects etcd backups. Types such as **kubernetes.io/dockerconfigjson** and **kubernetes.io/tls** cue built-in consumers. **imagePullSecrets** on **Pod** or **ServiceAccount** tie registry auth to pulls. Rotation means **update Secret** then **reload** workloads that cache values.

**Prerequisites:** [2.7.1 ConfigMaps](../01-configmaps/README.md).

## Flow of this lesson

```
  Secret (namespaced, typed)
              │
              ├── volumeMount (files, tmpfs on many setups)
              ├── envFrom (avoid when possible)
              └── imagePullSecrets → registry auth
```

**Say:**

**base64** is **encoding**, not **security**—anyone with **get secret** can recover bytes.

## Learning objective

- Contrast **Secret** consumption via **volume** vs **environment**.
- Name **dockerconfigjson** and **tls** secret types and typical uses.
- List Secrets safely in triage (**metadata only**) vs printing **data**.

## Why this matters

Leaked **kubeconfig** plus broad **secret list** equals breach; least-privilege RBAC starts with understanding Secret scope.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/07-configuration/02-secrets" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Teaching notes stored as a ConfigMap in **kube-system** (not a Secret—by design for universal apply).

**Run:**

```bash
kubectl apply -f yamls/2-7-2-secrets-notes.yaml
kubectl get cm -n kube-system 2-7-2-secrets-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-7-2-secrets-notes` when RBAC allows.

---

## Step 2 — Run inspect script

**What happens when you run this:**

Lists **Secrets** in all namespaces—avoid piping to public logs in real incidents.

**Run:**

```bash
bash scripts/inspect-2-7-2-secrets.sh
```

**Expected:** Secret list (names/types); script exits 0.

---

## Step 3 — Explain Secret volume projection (read-only)

**What happens when you run this:**

Shows Pod **secret** volume schema.

**Run:**

```bash
kubectl explain pod.spec.volumes.secret 2>/dev/null | head -n 25 || true
kubectl explain serviceaccount.imagePullSecrets 2>/dev/null | head -n 15 || true
```

**Expected:** Explain output or fallback on old clients.

## Video close — fast validation

```bash
kubectl get secrets -A --no-headers 2>/dev/null | head -n 15 || true
kubectl explain secret.type 2>/dev/null | head -n 12 || true
```

## Troubleshooting

- **`ImagePullBackOff` + pull secret** → wrong **dockerconfigjson** format or **namespace** of secret
- **Permission denied reading secret** → **RBAC** `get` on **secrets** resource
- **Env did not update** → env is fixed at container start—restart Pod or use **volume**
- **TLS handshake fail** → **tls.crt** / **tls.key** keys mismatch or wrong **mountPath**
- **etcd backup exposure** → enable **encryption at rest** + restrict **etcd** access

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-2-7-2-secrets.sh` | `kubectl get secrets -A` |
| `yamls/2-7-2-secrets-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-7-2-secrets-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.7.3 Liveness, Readiness, and Startup Probes](../03-liveness-readiness-and-startup-probes/README.md)
