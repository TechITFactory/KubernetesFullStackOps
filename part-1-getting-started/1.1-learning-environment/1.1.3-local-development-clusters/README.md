# 1.1.3 Local Development Clusters

- **Summary**: Bootstrap a consistent, resource-governed development namespace on any local cluster (Minikube or Kind) using a prerequisite check, namespace baseline, and a demo workload.
- **Content**: Why namespaces matter, what ResourceQuota and LimitRange do and when they fire, idempotent workspace bootstrapping, verifying cluster access.
- **Lab**: Run `check-local-prereqs.sh`, run `bootstrap-dev-workspace.sh`, inspect the namespace and running workload, run `teardown.sh` to clean up.

## Files

| Path | Purpose |
|------|---------|
| `scripts/check-local-prereqs.sh` | Checks for kubectl, docker, minikube, kind, helm — reports missing tools |
| `scripts/bootstrap-dev-workspace.sh` | Idempotent: applies namespace, quota, limit-range, and demo workload; waits for rollout |
| `scripts/teardown.sh` | Idempotent: deletes the `dev-local` namespace, no-op if already gone |
| `yamls/dev-namespace.yaml` | Namespace `dev-local` with course labels |
| `yamls/resource-quota.yaml` | Hard caps: 2 CPU / 2Gi memory requests, 4 CPU / 4Gi limits, max 20 pods |
| `yamls/limit-range.yaml` | Per-container defaults: 100m/128Mi requests, 500m/512Mi limits |
| `yamls/whoami-deployment.yaml` | Demo app + ClusterIP service — confirms networking and scheduling work |

## Quick Start

```bash
./scripts/check-local-prereqs.sh
./scripts/bootstrap-dev-workspace.sh
kubectl get all -n dev-local
kubectl port-forward svc/whoami 8080:80 -n dev-local
curl localhost:8080
./scripts/teardown.sh
```

---

## Transcript — 10-Minute Lesson

### [0:00–0:45] Hook

You now have a cluster running — either Minikube or Kind. The cluster is empty. It is like moving into a new apartment: the structure is there, but there are no shelves, no labels on the rooms, no rules about who can use the kitchen.

If you just start throwing everything into the `default` namespace without any structure, things get messy fast. You will accidentally delete the wrong resource, one runaway pod will eat all the memory, and you will have no idea which pod belongs to which lesson.

This lesson sets up your **workspace** — a properly governed namespace that we will use throughout the course.

---

### [0:45–2:30] What Is a Namespace?

A **namespace** in Kubernetes is like a folder on your computer.

When you save files, you organise them into folders — `Documents`, `Photos`, `Work`. If everything is on the Desktop with no folders, it becomes chaos.

Kubernetes has the same problem. If everyone puts everything in the same place — called `default` — it becomes impossible to manage. Namespaces solve this.

Each namespace is an isolated space:
- Resources in different namespaces can have the same name without conflict.
- You can apply security rules (RBAC) per namespace — the `dev` team sees their namespace, the `ops` team sees theirs.
- You can delete an entire namespace and everything in it disappears cleanly, with one command.

**Real world**: at most companies, Kubernetes namespaces map to teams, environments, or applications:
- `team-payments`, `team-orders`, `team-auth` — one namespace per team.
- `dev`, `staging`, `production` — one namespace per environment on shared clusters.
- `nginx-ingress`, `cert-manager`, `monitoring` — one namespace per infrastructure component.

---

### [2:30–4:30] ResourceQuota — The Namespace Budget

Okay, you have a namespace. Now imagine one developer's app has a bug — an infinite loop that keeps creating pods and consuming CPU. Without limits, it could crash the entire cluster and take down every other team's work.

A **ResourceQuota** puts a hard cap on what a namespace can consume in total.

Look at `resource-quota.yaml`:

```yaml
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi
    pods: "20"
```

This says: the entire `dev-local` namespace together cannot request more than 2 CPU cores and 2Gi of memory. The total limits cannot exceed 4 CPU and 4Gi. And there can be at most 20 pods.

If you try to create a 21st pod, Kubernetes rejects it immediately with a quota error. The cluster is protected.

**Real world**: in a shared company cluster, every team gets a namespace with a quota. The platform team (the cluster operators) sets the budgets based on what each team needs. If a team needs more, they file a request. This prevents any one team from accidentally — or maliciously — monopolising shared infrastructure.

---

### [4:30–6:00] LimitRange — Per-Container Defaults

The ResourceQuota protects the namespace as a whole. But what about individual pods?

Here is the problem: if a developer forgets to put `resources:` in their pod spec — no requests, no limits — Kubernetes has no idea how much CPU or memory to reserve. The scheduler might put too many pods on one node. Or a pod might use unlimited memory and get OOM-killed.

A **LimitRange** solves this by providing automatic defaults.

Look at `limit-range.yaml`:

```yaml
spec:
  limits:
    - type: Container
      default:
        cpu: 500m
        memory: 512Mi
      defaultRequest:
        cpu: 100m
        memory: 128Mi
```

This says: if a container is created without specifying resources, automatically give it `requests: 100m CPU / 128Mi memory` and `limits: 500m CPU / 512Mi memory`.

The developer's pod gets sensible defaults without them having to think about it. And the ResourceQuota can now calculate totals correctly because every pod has resources defined.

**The relationship between the two**:
- LimitRange = defaults for each individual container.
- ResourceQuota = total budget for the entire namespace.

They work together. LimitRange fills in the gaps; ResourceQuota enforces the ceiling.

**Real world**: platform teams almost always deploy both together. Without LimitRange, ResourceQuota rejects any pod that has no resource spec — making it annoying for developers. With both, the system is flexible but governed.

---

### [6:00–7:15] The Prerequisite Check Script

Before we bootstrap, run the check:

```bash
./scripts/check-local-prereqs.sh
```

Output looks like this:

```
[OK] kubectl
[OK] docker
[OPTIONAL] minikube not found
[OK] kind
[OPTIONAL] helm not found

Current kubectl context:
kind-kfsops-kind
```

The script uses a simple `check()` function that looks up each tool with `command -v`. `kubectl` is marked `required` — everything else is `optional`. If `kubectl` is missing, you cannot proceed. Everything else is a heads-up.

It also prints your current `kubectl` context so you know which cluster you are about to bootstrap. Before running the next script, make sure the context points at your local cluster — not a production cluster.

---

### [7:15–8:30] The Bootstrap Script

```bash
./scripts/bootstrap-dev-workspace.sh
```

The script runs in five steps, all idempotent:

**Step 1** — cluster reachability check:
```bash
kubectl cluster-info >/dev/null 2>&1 || { echo "Cannot reach cluster"; exit 1; }
```
If `kubectl` cannot reach a cluster, the script stops immediately with a clear message. No confusing partial failures.

**Step 2** — apply the namespace:
```bash
kubectl apply -f dev-namespace.yaml
```
`kubectl apply` is declarative — if the namespace already exists, nothing changes. Safe to run again.

**Step 3 and 4** — apply the quota and limit-range. Same idempotency: apply compares the live cluster state against the file and only patches differences.

**Step 5** — apply the whoami deployment:
```bash
kubectl apply -f whoami-deployment.yaml
kubectl rollout status deployment/whoami -n dev-local --timeout=60s
```
Waits until the pod is fully ready before printing the final status. If it takes more than 60 seconds something went wrong, the script fails, and you investigate.

Test it:
```bash
kubectl port-forward svc/whoami 8080:80 -n dev-local
curl localhost:8080
```

You will see a response from `traefik/whoami` — it prints hostname, IP, request headers. This proves DNS resolution, service routing, and pod scheduling all work correctly inside your namespace.

---

### [8:30–9:30] Real World — This Pattern Everywhere

This three-layer pattern — **Namespace + ResourceQuota + LimitRange** — is one of the most common patterns in production Kubernetes. You will see it in:

**Platform engineering**: a platform team maintains a GitOps repo where each folder is a namespace. Namespaces are created by merging a PR. ResourceQuotas are set per team. New developers get their namespace automatically.

**Multi-tenant SaaS**: each customer gets their own namespace on a shared cluster. Quotas prevent one customer from affecting others. This is called "soft multi-tenancy."

**Compliance**: some industries require resource isolation between workloads. Namespaces provide the boundary; quotas and limit-ranges enforce it.

**Cost attribution**: in cloud environments, namespaces map to cost centres. Tools like Kubecost read resource usage per namespace and charge it back to the right team.

The `whoami` workload is also a real-world pattern — a lightweight HTTP service that echoes request details, used constantly for debugging networking: "is my Ingress routing correctly? which pod is receiving my traffic?"

---

### [9:30–10:00] Recap

- **Namespace** = folder for Kubernetes resources. Isolates, organises, and enables per-team security.
- **ResourceQuota** = namespace-level budget. Prevents any one namespace from consuming more than its share.
- **LimitRange** = per-container defaults. Fills in missing resource specs automatically so quotas work and schedulers have accurate data.
- **check-local-prereqs.sh** = fast sanity check before bootstrapping, reports required and optional tools.
- **bootstrap-dev-workspace.sh** = idempotent: checks cluster reachability, applies all four manifests, waits for rollout.
- **teardown.sh** = deletes the namespace (and everything in it) cleanly, no-op if already gone.

Clean up:

```bash
./scripts/teardown.sh
```

Your local environment is now set up. In Part 2 we move into Kubernetes Concepts — understanding what is actually happening under the hood when you run `kubectl apply`.
