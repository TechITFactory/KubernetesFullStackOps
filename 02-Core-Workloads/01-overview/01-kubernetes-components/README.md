# Kubernetes Components — teaching transcript





## Intro





Alright — in this lesson we're not reading about Kubernetes components. We're finding them in your running cluster.





Every Kubernetes installation has the same set of components: the API server, etcd, the scheduler, the controller manager, kubelet, kube-proxy, and a container runtime. The official docs show you a diagram. This lesson shows you where those components actually live as processes and pods — so when something breaks, you know exactly which component to look at and how to check it.





**Prerequisites:** [Part 1](../../01-Local-First-Operations/README.md) — you need a reachable cluster and working `kubectl`.





**Teaching tip:** **What happens when you run this** is below each Run block. See **WHAT THIS DOES WHEN YOU RUN IT** in `scripts/inspect-k8s-components.sh`.





## One-time setup





```bash


COURSE_DIR="$HOME/K8sOps"


cd "$COURSE_DIR/02-Core-Workloads/01-overview/01-kubernetes-components"


```





> If you set `COURSE_DIR` earlier, skip the export and just `cd`.





## Flow of this lesson





```


  [ Step 1 ]           [ Step 2 ]              [ Step 3 ]


  inspect script   →   get kube-system    →   apply components


  + chmod              pods wide               map (optional)


```





**Say:**





We run the bundled inspector, then list `kube-system` pods to map processes to names, then optionally apply a reference ConfigMap if RBAC allows.





---





## Control plane and nodes





```


  Control plane


  ┌─────────────────────────────────────────┐


  │  kube-apiserver  ──────────  etcd       │


  │       ▲                                 │


  │       │                                 │


  │  kube-scheduler                         │


  │  kube-controller-manager               │


  └─────────────────────────────────────────└


           │  (API calls)


  Each node


  ┌─────────────────────────────────────────┐


  │  kubelet  →  CRI / container runtime    │


  │  kube-proxy                             │


  └─────────────────────────────────────────└


```





**Say:**





The control plane holds **kube-apiserver** (HTTP front door), **etcd** (persistence), **kube-scheduler** (placement), and **kube-controller-manager** (built-in controllers). Each node runs **kubelet** (node agent), **kube-proxy** (Service dataplane rules), and the **container runtime** (images and containers via CRI). Static pods for control-plane components often appear in `kube-system` on kubeadm-style clusters.





---





## Step 1 — Make scripts executable and run the component inspector





**What happens when you run this:**


`chmod +x scripts/*.sh` marks scripts executable. `inspect-k8s-components.sh` lists pods in `kube-system` and nodes, then hits `/readyz?verbose` on the API server — the modern replacement for the deprecated `componentstatuses` endpoint. Read-only.





**Say:**


The script gives me three things at once: what's running in `kube-system`, what nodes exist, and whether the API server reports itself healthy. I run this at the start of any troubleshooting session.





**Run:**





```bash


cd "$COURSE_DIR/02-Core-Workloads/01-overview/01-kubernetes-components"


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


This ConfigMap is a reference card. Any engineer with cluster access can read it with `kubectl get cm components-map -n kube-system -o yaml`. On **managed clusters** your user is often **Forbidden** from writing `kube-system` — edit the manifest’s `metadata.namespace` to **`default`** for the video take, or skip the apply and just read the YAML from git.





**Run:**





```bash


kubectl apply -f yamls/components-map.yaml


```





**Expected:**


ConfigMap created or unchanged. If you get a `Forbidden` error, your kubeconfig doesn't have write access to `kube-system` — that's fine, skip this step.





---





## What each component does





**kube-apiserver** — the front door; every `kubectl` call and controller watch flows through it.





**etcd** — durable key-value store for all API objects; protect it like a database.





**kube-scheduler** — chooses a suitable node for each schedulable pod and writes `spec.nodeName`.





**kube-controller-manager** — runs Deployment, ReplicaSet, Node, Job, and other built-in controllers that reconcile spec with reality.





**kubelet** — node agent that talks to the API and drives the runtime to run pod containers and report status.





**kube-proxy** — programs node-level rules so Service IPs reach healthy endpoints.





**Container runtime** — pulls images and runs containers; kubelet reaches it through the CRI socket (containerd, CRI-O, or cri-dockerd in this course).





---





## Troubleshooting





- **Pod in `kube-system` in `CrashLoopBackOff`** → `kubectl logs <pod> -n kube-system` and `kubectl describe pod <pod> -n kube-system` — the component itself will tell you why it's failing


- **`/readyz` returns non-ok lines** → those lines name the failing health check; each check maps to a specific subsystem (etcd connectivity, lease, etc.)


- **`kubectl get componentstatuses` is deprecated** → use `/readyz?verbose` instead (what the inspect script does)


- **Control-plane pods not visible** → on managed clusters (EKS, GKE, AKS) the control plane is hidden — you only see worker-side components; that's expected


- **`Forbidden` on `kube-system` write** → skip Step 3; your kubeconfig has read-only access





---





## Learning objective





- Named all seven core components (API server, etcd, scheduler, controller-manager, kubelet, kube-proxy, container runtime) and their roles.


- Used `kube-system` pod names and `/readyz?verbose` output to reason about control-plane health.


- Handled RBAC denials on managed clusters by skipping `kube-system` writes or using `default`.





## Why this matters





When a cluster is degraded, the first question is which component failed. The component map sends you to the right logs instead of every log.





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





**Expected:**





Nodes Ready; static pods or addons listed; message if `componentstatuses` is gone.





---





## Repo files (reference)





| Path | Purpose |


|------|---------|


| `scripts/inspect-k8s-components.sh` | Pods, nodes, `/readyz?verbose` |


| `yamls/components-map.yaml` | Component reference ConfigMap |


| `yamls/failure-troubleshooting.yaml` | Component visibility and API health issues |





---





## Next





[2.1.2 Objects in Kubernetes](../02-objects-in-kubernetes/README.md)


