# Part 1: GETTING STARTED



## Intro



Hands-on path: **01** (local cluster plus `dev-local` workspace) → **1.2** (production-style runtime plus kubeadm plus cloud trade-offs) → **03** (operational habits: scale, zones, nodes, security, PKI). Complete [Phase 1 — Prerequisites](../00-Prerequisites/README.md) first unless you already have Linux shell and container basics.



## One-time setup



```bash

COURSE_DIR="$HOME/K8sOps"

cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations"

```



> If you set `COURSE_DIR` in Part 0, it is still set — skip the export and just `cd`.



## Flow of this lesson



```

  ┌─────────────────────────────┐    ┌───────────────────────────────────┐

  │       On your laptop        │    │       Production-style path        │

  │                             │    │                                   │

  │  01 Minikube             │    │  1.2.1 CRI runtime on Linux nodes │

  │     or                      │    │           │                       │

  │  02 Kind                 │    │           ▼                       │

  │           │                 │    │  1.2.2 kubeadm lifecycle          │

  │           ▼                 │    │           │                       │

  │  03 dev-local workspace  │    │           ▼                       │

  └──────────┬──────────────────┘    │  1.2.3 Managed K8s trade-offs    │

             │                       └──────────────┬────────────────────┘

             │                                      │

             └──────────────────┬───────────────────┘

                                ▼

                     ┌─────────────────────┐

                     │  03 Best practices │

                     └─────────────────────┘

```



**Say:**



Part 1 splits into three tracks you can mix with your environment: a laptop cluster, a Linux-node production-style path, and a best-practices capstone. Most learners run **01** first, optionally **1.2** when they touch real nodes, then **03** before treating any cluster as production-like.



---



## Step 1 — Open Part 1 in the terminal



**What happens when you run this:**



`cd` moves into `01-Local-First-Operations`. `pwd` confirms the path. No cluster commands run yet.



**Say:**



I anchor my shell in Part 1 so relative links to `01-learning-environment` and scripts resolve the same way in the videos.



**Run:**



```bash

cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations"

pwd

```



**Expected:**



Path ending with `01-Local-First-Operations`.



---



## Step 2 — Follow the recommended sequence (reading step)



**What happens when you run this:**



You open the linked lessons in order — no command required unless a lesson tells you to run something.



**Say:**



I pick **01.1** or **01.2**, never both for the same clean track unless I know why. After that I open **03** for `dev-local`. **1.2** is for Linux lab nodes; **03** is the operational polish.



**Run:**



_(Read and follow the numbered list under **Recommended order** below.)_



**Expected:**



You know your next concrete lesson URL (starts with **01.1** or **01.2**).



---



## Recommended order (sequential)



Follow this when you want a single clean track from zero to “Part 1 done”:



1. [Part 0 — Prerequisites](../00-Prerequisites/README.md) — 0.1 Linux, 0.2 Docker.

2. [01 Minikube](01-learning-environment/01-minikube-setup/README.md) **or** [02 Kind](01-learning-environment/02-kind-in-docker/README.md) (pick one local stack).

3. [03 Local development clusters](01-learning-environment/03-local-development-clusters/README.md) — `dev-local` workspace on that cluster.

4. [1.2.1 Container runtimes](02-production-environment/1.2.1-container-runtimes/README.md) — pick **one** of [containerd](02-production-environment/1.2.1-container-runtimes/1.2.01-containerd/README.md) / [CRI-O](02-production-environment/1.2.1-container-runtimes/1.2.1.2-cri-o/README.md) / [Docker + cri-dockerd](02-production-environment/1.2.1-container-runtimes/1.2.03-docker-engine-via-cri-dockerd/README.md) on Linux lab nodes (skip if you stay only on local Minikube/Kind for now).

5. [1.2.2 Installing Kubernetes](02-production-environment/1.2.2-installing-kubernetes-with-deployment-tools/README.md) — kubeadm track **1.2.2.01 → 1.2.2.1.9** in order under [Bootstrapping with kubeadm](02-production-environment/1.2.2-installing-kubernetes-with-deployment-tools/1.2.2.1-bootstrapping-clusters-with-kubeadm/README.md).

6. [1.2.3 Turnkey cloud](02-production-environment/1.2.3-turnkey-cloud-solutions/README.md) — managed K8s trade-offs and CLI readiness.

7. [03 Best practices](03-best-practices/README.md) — 03.1 through 03.5 in order (or prioritize 03 before joining production-like nodes). Start the module with `bash 03-best-practices/scripts/verify-1-3-module-readiness.sh` from the `01-Local-First-Operations` directory.



---



## Troubleshooting



- **`kubectl` targets the wrong cluster** → `kubectl config current-context`; switch with `kubectl config use-context <name>` before any apply

- **`cd: no such file or directory` for `COURSE_DIR`** → set `COURSE_DIR` to the directory where you cloned this repo (for example `$HOME/K8sOps`)

- **`verify-1-3-module-readiness.sh` not found** → run it only after `cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations"`

- **Unclear whether to study 1.2** → skip **1.2** until you have Linux nodes to prepare; stay on **01** + **03** for pure laptop learning

- **Part 2 lessons feel disconnected from the cluster** → from repo root run `bash 02-Core-Workloads/scripts/verify-part2-prerequisites.sh` after Part 1 cluster work



---



## Learning objective



- Opened `01-Local-First-Operations` from `$COURSE_DIR` and understood the three tracks (01, 1.2, 03).

- Chose Minikube **or** Kind and knew that **03** follows immediately after.

- Located **03** readiness script path for the day you start best practices.



## Why this matters



Part 1 is the spine of the course: without a consistent path through local cluster, optional node prep, and operational habits, later concepts have nothing concrete to attach to.



## Video close — fast validation



**What happens when you run this:**



Prints current context, node list, first ~25 pods cluster-wide, and control-plane endpoint URL — all read-only API checks.



**Say:**



When I finish Part 1, I still expect a reachable API and sane node state. These four lines are the fast green-light check.



**Run:**



```bash

kubectl config current-context

kubectl get nodes -o wide

kubectl get pods -A | head -n 25

kubectl cluster-info

```



**Expected:**



Context matches the cluster you expect; nodes `Ready`; `kube-system` and `dev-local` (if used) are not crash-looping; `cluster-info` prints a control-plane URL.



---



## Repo files (reference)



| Path | Purpose |

|------|---------|

| `01-learning-environment/` | Minikube or Kind, then `dev-local` |

| `02-production-environment/` | Runtimes, kubeadm, managed K8s |

| `03-best-practices/scripts/verify-1-3-module-readiness.sh` | Gate before **03** labs |



---



## Modules



- [01 Learning Environment](01-learning-environment/README.md) — Minikube *or* Kind, then governed `dev-local` namespace.

- [1.2 Production Environment](02-production-environment/README.md) — CRI runtime, kubeadm lifecycle, managed Kubernetes.

- [03 Best Practices](03-best-practices/README.md) — Pre-scale checks, multi-zone, validation, PSS, PKI.



---



## Next



Start [01 Learning Environment](01-learning-environment/README.md) or continue the numbered track you chose in Step 2.



**Next after Part 1:** [Part 2 — Concepts](../02-Core-Workloads/README.md). Run `bash 02-Core-Workloads/scripts/verify-part2-prerequisites.sh` from the repo root so `cluster-info` and `/readyz` succeed before reading 2.1.

