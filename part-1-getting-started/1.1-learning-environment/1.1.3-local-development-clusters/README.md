# 1.1.3 Local Development Clusters — teaching transcript

## Intro

You already have a cluster from **Minikube (1.1.1)** **or** **Kind (1.1.2)**. This lesson adds a **workspace** you will reuse: namespace **`dev-local`**, a **ResourceQuota** (namespace budget), a **LimitRange** (default container resources), and a small **whoami** app.

**Before you start:** `kubectl config current-context` must be your **local** cluster.

- **Kind:** use context **`kind-kfsops-kind`** (e.g. `kubectl config use-context kind-kfsops-kind` before bootstrapping).

Replace **`/path/to/K8sOps`** with your clone path.

**Teaching tip:** Each step includes **What happens when you run this** before **Run**. Shell scripts document the same behavior in a header comment at the top of each file under `scripts/`.

---

## Step 1 — Open this lesson in the terminal

**What happens when you run this:**  
`cd` into the lesson; `pwd` prints path; `chmod +x scripts/*.sh` makes scripts runnable — no cluster objects changed.

**Run:**

```bash
cd /path/to/K8sOps/part-1-getting-started/1.1-learning-environment/1.1.3-local-development-clusters
pwd
chmod +x scripts/*.sh
```

**Expected:**  
Path ends with `1.1.3-local-development-clusters`.

---

## Step 2 — Check tools and current context

**What happens when you run this:**  
`check-local-prereqs.sh` prints which CLIs exist and shows current context (read-only). `kubectl config current-context` prints the active context name — **this** cluster receives later applies.

**Say:**  
I verify `kubectl` and see **which cluster** will get `dev-local` — not production.

**Run:**

```bash
./scripts/check-local-prereqs.sh
kubectl config current-context
```

**Expected:**  
`[OK] kubectl`; context is local (e.g. `minikube` or `kind-kfsops-kind`).

---

## Step 3 — Bootstrap `dev-local`

**What happens when you run this:**  
`bootstrap-dev-workspace.sh` `kubectl apply`s namespace, ResourceQuota, LimitRange, and whoami Deployment/Service, then `kubectl rollout status` until ready — all in namespace `dev-local` on the current context.

**Say:**  
The script applies namespace, quota, limit range, and whoami; it waits for rollout. Uses your **current** kubectl context.

**Run:**

```bash
./scripts/bootstrap-dev-workspace.sh
```

**Expected:**  
`Development workspace bootstrap complete.`; `kubectl get all -n dev-local` shows Deployment, Service, pods.

---

## Step 4 — Inspect quota and limits

**What happens when you run this:**  
`kubectl get` / `describe` read ResourceQuota and LimitRange objects from the API — no mutations.

**Say:**  
These objects are what platform teams use to keep one team from starving others.

**Run:**

```bash
kubectl get resourcequota -n dev-local
kubectl get limitrange -n dev-local
kubectl describe quota -n dev-local
```

**Expected:**  
Quota and LimitRange listed; describe shows hard limits / defaults.

---

## Step 5 — Hit whoami via port-forward

**What happens when you run this:**  
First terminal: `kubectl port-forward` opens a local TCP listener on **8080** and proxies to the Service’s port **80** inside the cluster (process runs until Ctrl+C). Second terminal: `curl` sends one HTTP request to localhost and prints only the status code.

**Say:**  
Service is ClusterIP — I forward **local 8080** to **service port 80** to test without Ingress.

**Run:**

```bash
kubectl port-forward svc/whoami 8080:80 -n dev-local
```

**In a second terminal:**

```bash
curl -sS -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8080/
```

**Expected:**  
Port-forward stays running; `curl` prints **200** (stop port-forward with Ctrl+C when done).

---

## Step 6 — Module wrap commands

**What happens when you run this:**  
Three read-only `kubectl get` calls: namespace existence, quota + limitrange, pods — recap only.

**Run:**

```bash
kubectl get ns dev-local
kubectl get quota,limitrange -n dev-local
kubectl get pods -n dev-local -o wide
```

**Expected:**  
Namespace exists; quota and limit range bound; pod(s) Running.

---

## Step 7 — Tear down `dev-local` (optional)

**What happens when you run this:**  
`teardown.sh` runs `kubectl delete namespace dev-local` if it exists — removes all objects in that namespace (cascade delete).

**Run:**

```bash
./scripts/teardown.sh
```

**Expected:**  
Namespace deleted or already gone.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/check-local-prereqs.sh` | Tool + context sanity check |
| `scripts/bootstrap-dev-workspace.sh` | Applies all manifests + rollout wait |
| `scripts/teardown.sh` | Deletes namespace `dev-local` |
| `yamls/dev-namespace.yaml` | Namespace + labels |
| `yamls/resource-quota.yaml` | Namespace caps |
| `yamls/limit-range.yaml` | Default container requests/limits |
| `yamls/whoami-deployment.yaml` | Demo app + ClusterIP Service |
| `yamls/failure-troubleshooting.yaml` | Quota / rollout hints |

---

## Troubleshooting

- **Wrong cluster** → `kubectl config current-context`; switch before Step 3
- **Cannot reach cluster** → start Minikube or Kind; `kubectl cluster-info`
- **Quota denied creating pods** → `kubectl describe quota -n dev-local`; reduce other workloads or adjust YAML for lab only
- **Rollout timeout** → `kubectl describe pod -n dev-local`; image pull / events
- **Port-forward address already in use** → use `8081:80` and `curl :8081`

---

## Learning objective

- Explain namespace vs ResourceQuota vs LimitRange; bootstrap `dev-local`; verify with port-forward.

## Why this matters

Shared clusters use this **three-layer** pattern everywhere: isolate by namespace, cap totals, default per-container resources.

## Next

Continue with **Part 1** (e.g. [1.2 Production environment](../../1.2-production-environment/README.md)) or **Part 2 Concepts** when your course path says so.
