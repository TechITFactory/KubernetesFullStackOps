# 2.1.4 The kubectl Command-Line Tool — teaching transcript

## Intro

`kubectl` is the tool you'll use more than any other in this course — and most of your career as a Kubernetes operator.

It's not just a way to talk to the cluster. It's how you inspect state, debug problems, apply changes safely, and understand what's running. The difference between someone who knows `kubectl get pods` and someone who knows `kubectl get pods -o jsonpath`, `kubectl rollout status`, `kubectl exec`, and `kubectl debug` is the difference between knowing the basics and being productive under pressure.

This lesson covers the foundational habits: always knowing which cluster you're talking to before you change anything, using output formats effectively, and applying manifests with the practice namespace.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

---

## Flow of this lesson

**Say:**
Two steps — run the essentials script to see context, namespaces, and output formats in action, then apply the practice namespace manifest.

```
  [ Step 1 ]                    [ Step 2 ]
  kubectl-essentials.sh  →      Apply practice
  (context, formatting)         namespace
```

---

## Step 1 — Run the kubectl essentials script

**What happens when you run this:**
`chmod +x scripts/*.sh` makes the script executable. `kubectl-essentials.sh` runs: `kubectl config current-context` (which cluster am I talking to?), `kubectl get ns` (what namespaces exist?), a sample `kubectl api-resources` filtered view, and a custom-columns node view showing name and status. All read-only.

**Say:**
I always know which cluster I'm on before I run anything that changes state. `kubectl config current-context` is the first command in every shell session on a cluster. One wrong context and you're applying to production when you meant staging. Make this a reflex.

**Run:**

```bash
chmod +x scripts/*.sh
./scripts/kubectl-essentials.sh
```

**Expected:**
Context name printed; namespace list; filtered api-resources; custom node columns. No auth errors.

---

## Step 2 — Apply the practice namespace

**What happens when you run this:**
`kubectl apply -f yamls/kubectl-practice-namespace.yaml` creates namespace `kubectl-practice`. `kubectl get ns kubectl-practice` confirms it exists.

**Say:**
This namespace is the sandbox for kubectl practice commands. Anything you apply here is isolated — it won't affect the rest of the cluster. Creating it with `apply` (not `create`) means I can re-run this any time without errors.

**Run:**

```bash
kubectl apply -f yamls/kubectl-practice-namespace.yaml
kubectl get ns kubectl-practice
```

**Expected:**
Namespace `kubectl-practice` listed with `Active` status.

---

## Essential kubectl patterns

**Context and namespace:**
```bash
kubectl config current-context           # which cluster
kubectl config get-contexts              # list all contexts
kubectl config use-context <name>        # switch cluster
kubectl config set-context --current --namespace=<ns>  # switch namespace
```

**Output formats:**
```bash
kubectl get pods -o wide                 # extra columns: node, IP
kubectl get pods -o yaml                 # full object YAML
kubectl get pods -o json                 # full object JSON
kubectl get pods -o jsonpath='{.items[*].metadata.name}'  # extract field
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase
```

**Watching:**
```bash
kubectl get pods -w                      # stream updates
kubectl rollout status deployment/<name> # wait for rollout
kubectl wait --for=condition=available deployment/<name> --timeout=120s
```

**Debugging:**
```bash
kubectl describe pod <name>              # events + full spec
kubectl logs <pod>                       # container stdout
kubectl logs <pod> -c <container>        # specific container
kubectl exec -it <pod> -- /bin/sh        # shell into container
kubectl debug <pod> -it --image=busybox  # debug sidecar
```

**Applying and cleaning up:**
```bash
kubectl apply -f manifest.yaml           # declarative apply
kubectl delete -f manifest.yaml          # delete what the manifest created
kubectl apply -f manifest.yaml --dry-run=client -o yaml  # preview changes
kubectl diff -f manifest.yaml            # diff current vs manifest
```

---

## The context habit

The single most common `kubectl` mistake is running a destructive command on the wrong cluster. Production and staging may use similar resource names. A quick `kubectl delete deployment api` against production because your context was wrong is an incident.

**Build this habit:**
1. Before any `apply`, `delete`, `patch`, or `exec` — run `kubectl config current-context`.
2. For anything that modifies state, set a permanent alias in your shell profile:
   ```bash
   alias kctx='kubectl config current-context'
   ```
3. Consider tools like `kubectx` and `kubens` (fair-source) that make context switching and namespace switching explicit and visible in your prompt.

---

## Troubleshooting

- **`error: You must be logged in to the server`** → your kubeconfig credentials have expired; re-authenticate with your cluster's auth method (OIDC refresh, `aws eks update-kubeconfig`, `gcloud container clusters get-credentials`, etc.)
- **`kubectl` commands are slow** → could be API server load, network latency, or slow etcd; check `kubectl cluster-info` response time as a baseline
- **Wrong output from `-o jsonpath`** → jsonpath syntax is strict; test with `-o json` first to see the full structure, then build the path; use `{range .items[*]}...{end}` for arrays
- **`kubectl exec` permission denied** → the container doesn't run as a user with shell access, or there's no shell in the image; try `kubectl debug` with a busybox or alpine sidecar instead

---

## Learning objective

- Run `kubectl config current-context` habitually before any state-changing command.
- Use at least three output formats (`wide`, `yaml`, `jsonpath`) to extract information.
- Apply a manifest, verify the result, and clean up — the complete lifecycle.

## Why this matters

`kubectl` proficiency is the single skill that most directly impacts how fast you can diagnose and fix problems in a cluster. A slow `kubectl` user spends minutes finding information that an experienced user reads in seconds. Every output format, every flag, every pattern in this lesson cuts time off real incidents.

---

## Video close — fast validation

**What happens when you run this:**
Context name; nodes; grep for the practice namespace — read-only.

**Say:**
Same three commands I'd run at the start of any kubectl session: context, nodes, and a quick namespace grep to confirm what I'm working with. These are the orientation checks.

```bash
kubectl config current-context
kubectl get nodes
kubectl get ns | grep kubectl-practice || true
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/kubectl-essentials.sh` | Context, namespace, formatting demo |
| `yamls/kubectl-practice-namespace.yaml` | Practice namespace |
| `yamls/failure-troubleshooting.yaml` | Context, RBAC, and output format issues |

---

## Next

[2.2 Cluster architecture](../../2.2-cluster-architecture/README.md)
