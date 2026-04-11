# 2.4.1.10 Downward API â€” teaching transcript

## Intro

The **Downward API** injects **Pod metadata** into containers without hardcoding cluster-specific strings. You can surface **name**, **namespace**, **labels**, **annotations**, and **resource requests/limits** as **environment variables** via **`valueFrom.fieldRef`** or as **files** under a **`downwardAPI` volume** (each key becomes a small file). Apps use this for **log tagging**, **metric labels**, **routing context**, or bootstrapping config that must match the Podâ€™s identity. **Environment** variables are fixed at container **start**; **volume projections** can refresh for some fields on kubelet periodic syncâ€”know which behavior your app assumes.

**Prerequisites:** [2.4.1.9 User Namespaces](../10-user-namespaces/README.md) recommended.

## Flow of this lesson

```
  Pod metadata in API
        â”‚
        â”œâ”€â”€ fieldRef â†’ env vars at container start
        â”‚
        â””â”€â”€ downwardAPI volume â†’ files under mountPath
```

**Say:**

Downward API answers â€œwho am I and where do I run?â€ without giving the app RBAC to the API server.

## Learning objective

- Use **env** and **volume** forms of the Downward API.
- List common **fieldRef** paths (name, namespace, labels, limits).
- Name use cases: **self-aware apps** and **log tagging**.

## Why this matters

Hardcoding namespace strings in twelve configs breaks multi-cluster promotion; Downward API keeps one image across environments.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/part-2-concepts/2.4-workloads/01-pods/11-downward-api" 2>/dev/null || cd .
```

## Step 1 â€” Apply demo and check env

**What happens when you run this:**

The **`app`** container receives env vars populated from **`fieldRef`**.

**Say:**

I grep **`POD_NAME`** so the audience sees a concrete injected value.

**Run:**

```bash
kubectl apply -f yamls/downward-api-demo.yaml
kubectl wait --for=condition=Ready pod/downward-api-demo --timeout=120s
kubectl exec pod/downward-api-demo -c app -- printenv | grep -E '^POD_NAME=' || true
```

**Expected:** Downward-injected metadata appears in env (and/or files per manifest).

---

## Step 2 â€” Describe environment and mounts

**What happens when you run this:**

`describe` prints the **Environment** stanza and volume mountsâ€”readable without `exec`.

**Say:**

If the manifest also projects a **downwardAPI** volume, I `exec cat` that path in a follow-on take.

**Run:**

```bash
kubectl get pod downward-api-demo -o wide
kubectl describe pod downward-api-demo | sed -n '/Environment:/,/Mounts:/p'
```

**Expected:** Environment entries show `fieldRef` sources; mounts list downward API paths if configured.

## Video close â€” fast validation

```bash
kubectl exec pod/downward-api-demo -c app -- printenv | grep -E '^POD_|^NAMESPACE' || true
kubectl get pod downward-api-demo -o wide
```

## Troubleshooting

- **Empty env** â†’ wrong **container name** with `-c`; or field path unsupported on your version
- **Label key missing** â†’ `fieldRef` for labels requires exact key; typo yields empty string or error
- **Limits not shown** â†’ requests/limits must exist for resourceFieldRef to resolve
- **Stale env** â†’ env is fixed at start; change requires pod restart; prefer volume if you need refresh
- **`Forbidden`** â†’ PSA or namespace policy blocking projected volumes
- **Volume not mounted** â†’ check **mountPath** and container name

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/downward-api-demo.yaml` | Env and/or volume Downward API demo |
| `yamls/failure-troubleshooting.yaml` | fieldRef mistakes |

## Cleanup

```bash
kubectl delete -f yamls/downward-api-demo.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.1.11 Advanced Pod Configuration](../12-advanced-pod-configuration/README.md)
