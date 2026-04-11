# 2.7.5 Organizing Cluster Access Using kubeconfig Files — teaching transcript

## Intro

A **kubeconfig** file holds **clusters** (API URL + CA), **users** (credentials: certs, tokens, **exec** plugins), and **contexts** that bind **cluster + user + namespace**. **`kubectl`** reads **`KUBECONFIG`** (list of files merged) or **`~/.kube/config`**. **`kubectl config use-context`** switches the active pair; **`kubectl config set-context`** updates defaults. **Service accounts** use **projected tokens** in-cluster; humans and CI use **kubeconfig** or **OIDC** plugins. Never commit **secrets** in kubeconfig to git—use **exec** auth or secret managers.

**Prerequisites:** [2.7.4 Resource Management](../04-resource-management-for-pods-and-containers/README.md).

## Flow of this lesson

```
  kubeconfig file(s)
        │
        ├── clusters: server + certificate-authority-data
        ├── users: client-certificate / token / exec
        └── contexts: cluster + user + namespace
              │
              ▼
  kubectl uses current-context
```

**Say:**

When **`kubectl`** hits the wrong cluster, I run **`current-context`** before **`delete`**—every time.

## Learning objective

- Describe **clusters**, **users**, and **contexts** in a kubeconfig.
- List and switch contexts with **`kubectl config`**.
- Explain **`KUBECONFIG`** merge when multiple files are set.

## Why this matters

Incidents worsen when operators **apply** to **prod** while thinking **dev**—context discipline is safety gear.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/07-configuration/05-organizing-cluster-access-using-kubeconfig-files" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

kubeconfig teaching notes in **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-7-5-organizing-cluster-access-using-kubeconfig-files-notes.yaml
kubectl get cm -n kube-system 2-7-5-organizing-cluster-access-using-kubeconfig-files-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-7-5-organizing-cluster-access-using-kubeconfig-files-notes` when allowed.

---

## Step 2 — Run inspect script

**What happens when you run this:**

Prints **contexts** and **current-context**—read-only.

**Run:**

```bash
bash scripts/inspect-2-7-5-organizing-cluster-access-using-kubeconfig-files.sh
```

**Expected:** Context list with `*` on current; script exits 0.

---

## Step 3 — View merged kubeconfig path (read-only)

**What happens when you run this:**

Shows which file(s) **`kubectl`** considers—environment dependent.

**Run:**

```bash
echo "KUBECONFIG=${KUBECONFIG:-~/.kube/config (default if unset and file exists)}"
kubectl config view --minify 2>/dev/null | head -n 40 || true
```

**Expected:** Minified YAML for current context (may redact nothing—avoid sharing publicly).

## Video close — fast validation

```bash
kubectl config get-contexts
kubectl config current-context
kubectl cluster-info 2>/dev/null || true
```

## Troubleshooting

- **`Unable to connect`** → wrong **server** in cluster block or VPN down
- **`x509: certificate signed by unknown authority`** → rotate **certificate-authority-data** from cluster admin
- **`You must be logged in`** → **exec** auth plugin token expired—re-login per IdP
- **Merged wrong file** → unset extra **`KUBECONFIG`** entries temporarily to isolate
- **Wrong namespace** → **`kubectl config set-context --current --namespace=`**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-2-7-5-organizing-cluster-access-using-kubeconfig-files.sh` | Contexts + current-context |
| `yamls/2-7-5-organizing-cluster-access-using-kubeconfig-files-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-7-5-organizing-cluster-access-using-kubeconfig-files-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.7.6 Resource Management for Windows Nodes](../06-resource-management-for-windows-nodes/README.md)
