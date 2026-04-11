# 2.8.10 Good Practices for Kubernetes Secrets — teaching transcript

## Intro

**Secrets** in etcd are **base64**, not **encrypted**, unless **encryption at rest** is configured (**KMS** integration recommended). **Good practices**: **narrow** **RBAC**, **avoid** env vars for **high-value** secrets, prefer **CSI** **secrets store** drivers or **external** vaults, **rotate** credentials and **restart** consumers, **audit** **`get secret`**, enable **immutable** secrets where updates are rare, and **scan** manifests for **accidental** **cleartext**. **Short-lived** **tokens** beat **long-lived** **kubeconfig** **embedded** certs when possible.

**Prerequisites:** [2.8.9 RBAC Good Practices](../09-role-based-access-control-good-practices/README.md); [2.7.2 Secrets](../../07-configuration/02-secrets/README.md).

## Flow of this lesson

```
  Secret created
        │
        ├── RBAC who can read?
        ├── encryption at rest (apiserver config)
        └── workload consumption (mount vs env vs CSI)
        │
        ▼
  Rotation + audit + external vault when needed
```

**Say:**

I repeat: **encryption at rest** protects **etcd** **backups**—**RBAC** protects **live** **API** **reads**.

## Learning objective

- List **defense layers** for **Kubernetes Secrets**.
- Run **`kubectl get secrets -A`** via the repo **inspect** script and discuss **metadata-only** triage.

## Why this matters

**Secret** sprawl in **every** **namespace** is **blast-radius** multiplication when **RBAC** slips.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/08-security/10-good-practices-for-kubernetes-secrets" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Secrets good-practices notes.

**Run:**

```bash
kubectl apply -f yamls/2-8-10-good-practices-for-kubernetes-secrets-notes.yaml
kubectl get cm -n kube-system 2-8-10-good-practices-for-kubernetes-secrets-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-8-10-good-practices-for-kubernetes-secrets-notes` when allowed.

---

## Step 2 — Run inspect script

**What happens when you run this:**

**`kubectl get secrets -A`**—avoid **logging** **values** in recordings.

**Run:**

```bash
bash scripts/inspect-2-8-10-good-practices-for-kubernetes-secrets.sh
```

**Expected:** Secret **list** (types/names only); exit 0.

---

## Step 3 — Count secrets per namespace (read-only)

**What happens when you run this:**

**jq**-free **`kubectl`** approximate: show first namespaces with secrets.

**Run:**

```bash
kubectl get secrets -A --no-headers 2>/dev/null | awk '{print $1}' | sort | uniq -c | sort -nr | head -n 15 || true
```

**Expected:** Histogram-style counts.

## Video close — fast validation

```bash
kubectl explain secret.immutable 2>/dev/null | head -n 12 || true
```

## Troubleshooting

- **Secret in Git** → **BFG** / **git-filter-repo** + **rotate** everything touched
- **etcd backup** exposure → **KMS** **encryption** + **offline** **key** **policy**
- **CSI driver** outage → pods **pending** **mount**—**graceful** **degradation** plan
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-2-8-10-good-practices-for-kubernetes-secrets.sh` | `kubectl get secrets -A` |
| `yamls/2-8-10-good-practices-for-kubernetes-secrets-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-8-10-good-practices-for-kubernetes-secrets-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.8.11 Multi-tenancy](../11-multi-tenancy/README.md)
