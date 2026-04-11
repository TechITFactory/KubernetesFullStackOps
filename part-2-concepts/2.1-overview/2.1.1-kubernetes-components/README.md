# 2.1.1 Kubernetes Components — teaching transcript

## Intro

Alright — in this lesson we're not reading about Kubernetes components. We're finding them in your running cluster.

Every Kubernetes installation has the same set of components: the API server, etcd, the scheduler, the controller manager, kubelet, kube-proxy, and a container runtime. The official docs show you a diagram. This lesson shows you where those components actually live as processes and pods — so when something breaks, you know exactly which component to look at and how to check it.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md) — you need a reachable cluster and working `kubectl`.

**Teaching tip:** **What happens when you run this** is below each Run block. See **WHAT THIS DOES WHEN YOU RUN IT** in `scripts/inspect-k8s-components.sh`.

---

## Control plane and nodes

**Say:**
Here's how the components split between the control plane and worker nodes. The control plane runs the brains — API server, etcd, scheduler, controller manager. Each worker node runs the muscle — kubelet drives the runtime, kube-proxy manages network rules.

```
  Control plane
  ┌─────────────────────────────────────────┐
  │  kube-apiserver  ──────────  etcd       │
  │       ▲                                 │
  │       │                                 │
  │  kube-scheduler                         │
  │  kube-controller-manager               │
  └─────────────────────────────────────────┘
           │  (API calls)
  Each node
  ┌─────────────────────────────────────────┐
  │  kubelet  →  CRI / container runtime    │
  │  kube-proxy                             │
  └─────────────────────────────────────────┘
```

Static pods for control-plane components often show up as Pods in `kube-system`. Worker nodes run kubelet, kube-proxy, and the runtime only.

---

## Step 1 — Make scripts executable and run the component inspector

**What happens when you run this:**
`chmod +x scripts/*.sh` marks scripts executable. `inspect-k8s-components.sh` lists pods in `kube-system` and nodes, then hits `/readyz?verbose` on the API server — the modern replacement for the deprecated `componentstatuses` endpoint. Read-only.

**Say:**
The script gives me three things at once: what's running in `kube-system`, what nodes exist, and whether the API server reports itself healthy. I run this at the start of any troubleshooting session.

**Run:**

```bash
chmod +x scripts/*.sh
./scripts/inspect-k8s-components.sh
```

**Expected:**
Pods in `kube-system` listed; nodes shown; `/readyz?verbose` returns `ok` lines for each health check.

---

## Step 2 — Inspect `kube-system` pods directly

**What happens when you run this:**
`kubectl get pods -n kube-system -o wide` lists all pods in `kube-system` with node placement and IP — read-only.

**Say:**
Here's what I'm looking for. On a kubeadm cluster, I expect to see `etcd-*`, `kube-apiserver-*`, `kube-controller-manager-*`, and `kube-scheduler-*` as static pods — their names include the node they're pinned to. Plus `coredns-*`, `kube-proxy-*`, and whatever CNI your cluster uses.

On Minikube or Kind you'll see the same set, just named slightly differently.

**Run:**

```bash
kubectl get pods -n kube-system -o wide
```

**Expected:**
Control-plane and add-on pods listed. All should be `Running` or `Completed`.

---

## Step 3 — Apply the components reference map

**What happens when you run this:**
`kubectl apply -f yamls/components-map.yaml` creates or updates a ConfigMap in `kube-system` that maps each component to its role, port, and binary name — documentation stored in the cluster. Needs write access to `kube-system`.

**Say:**
This ConfigMap is a reference card. Any engineer with cluster access can read it with `kubectl get cm components-map -n kube-system -o yaml`. It's also a useful place to record which version of each component your cluster runs.

**Run:**

```bash
kubectl apply -f yamls/components-map.yaml
```

**Expected:**
ConfigMap created or unchanged. If you get a `Forbidden` error, your kubeconfig doesn't have write access to `kube-system` — that's fine, skip this step.

---

## What each component does

**kube-apiserver** — the front door. Everything talks through it. `kubectl`, controllers, kubelet — all API calls go here. If this is down, the cluster is unreachable.

**etcd** — the database. Stores every Kubernetes object as key-value pairs. Losing etcd without a backup means losing the cluster's state. It runs as a static pod or external cluster.

**kube-scheduler** — assigns pods to nodes. Reads `spec.nodeName` is empty, picks a node based on resources and constraints, writes `spec.nodeName`. Does not start containers.

**kube-controller-manager** — runs all the built-in control loops: Deployment controller, ReplicaSet controller, Node controller, Job controller, and more. Each loop watches the API server and reconciles actual state toward desired state.

**kubelet** — the node agent. Runs on every node, reads pod specs from the API server, tells the CRI (container runtime interface) to start or stop containers. If a pod is `Pending` on a node, kubelet is the one trying to start it.

**kube-proxy** — manages iptables or IPVS rules on each node for Service routing. When you curl a Service ClusterIP, kube-proxy's rules decide which pod actually receives the connection.

**Container runtime** — the component that actually pulls images and starts containers. kubelet talks to it through the CRI socket. In Part 1 you installed containerd, CRI-O, or cri-dockerd.

---

## Troubleshooting

- **Pod in `kube-system` in `CrashLoopBackOff`** → `kubectl logs <pod> -n kube-system` and `kubectl describe pod <pod> -n kube-system` — the component itself will tell you why it's failing
- **`/readyz` returns non-ok lines** → those lines name the failing health check; each check maps to a specific subsystem (etcd connectivity, lease, etc.)
- **`kubectl get componentstatuses` is deprecated** → use `/readyz?verbose` instead (what the inspect script does)
- **Control-plane pods not visible** → on managed clusters (EKS, GKE, AKS) the control plane is hidden — you only see worker-side components; that's expected
- **`Forbidden` on `kube-system` write** → skip Step 3; your kubeconfig has read-only access

---

## Learning objective

- Name every Kubernetes component and its role.
- Find control-plane components in `kube-system` using `kubectl`.
- Read `/readyz?verbose` output and identify failing health checks.

## Why this matters

When a cluster is degraded, the first question is always: which component is responsible? An API server outage looks different from a scheduler stuck, which looks different from a kubelet not reporting. Knowing the component map means you go directly to the right log, not through all of them.

---

## Video close — fast validation

**What happens when you run this:**
Nodes; `kube-system` pods; `componentstatuses` if still served (deprecated but still present on some clusters) — read-only recap.

**Say:**
These three are my end-of-lesson health check. All nodes Ready, all kube-system pods Running or Completed, componentstatuses shows Healthy where it still works. If anything is off here, I fix it before moving to the next lesson.

```bash
kubectl get nodes -o wide
kubectl get pods -n kube-system
kubectl get componentstatuses 2>/dev/null || echo "(componentstatuses deprecated on this cluster — /readyz is the modern path)"
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-k8s-components.sh` | Pods, nodes, `/readyz?verbose` |
| `yamls/components-map.yaml` | Component reference ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Component visibility and API health issues |

---

## Next

[2.1.2 Objects in Kubernetes](../2.1.2-objects-in-kubernetes/README.md)
