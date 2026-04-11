# 1.2.2 Installing Kubernetes with Deployment Tools

## Intro

`kubeadm` is the official Kubernetes cluster bootstrapper. It initialises the control plane, issues certificates, joins nodes, and keeps configuration in files instead of ad hoc flags. This module walks that lifecycle on Linux nodes **after** you finish [1.2.1 Container runtimes](../1.2.1-container-runtimes/README.md) on every machine that will run kubelet.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/part-1-getting-started/1.2-production-environment/1.2.2-installing-kubernetes-with-deployment-tools"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  [ 1.2.2.1 kubeadm track ]          [ 1.2.3 cloud decision ]
  1.2.2.1.1 → … → 1.2.2.1.9          managed vs self-managed
         │                                    │
         └────────────────┬───────────────────┘
                          ▼
                   kubectl / production habits
```

**Say:**

The main path is **1.2.2.1** in order: install packages, troubleshoot, init, customise, HA theory, HA join, external etcd option, kubelet config, dual-stack. **1.2.3** is the parallel decision lesson for when the cloud runs the control plane instead.

---

## Step 1 — Open this module directory

**What happens when you run this:**

`cd` moves into `1.2.2-installing-kubernetes-with-deployment-tools`. `pwd` prints the path.

**Say:**

I anchor here before opening **1.2.2.1** or **1.2.3** so relative paths in the video stay stable.

**Run:**

```bash
cd "$COURSE_DIR/part-1-getting-started/1.2-production-environment/1.2.2-installing-kubernetes-with-deployment-tools"
pwd
```

**Expected:**

Path ending with `1.2.2-installing-kubernetes-with-deployment-tools`.

---

## Step 2 — Enter the kubeadm subsection (reading step)

**What happens when you run this:**

You open [1.2.2.1 Bootstrapping clusters with kubeadm](1.2.2.1-bootstrapping-clusters-with-kubeadm/README.md) and follow **1.2.2.1.1** through **1.2.2.1.9** in order for a self-built cluster.

**Say:**

I do not skip **1.2.2.1.1**; version-pinned packages are the foundation for every later kubeadm command.

**Run:**

_(Open [1.2.2.1 README](1.2.2.1-bootstrapping-clusters-with-kubeadm/README.md).)_

**Expected:**

You are on lesson **1.2.2.1.1** or know which sub-lesson matches your lab depth.

---

## Troubleshooting

- **`kubeadm: command not found`** → complete [1.2.2.1.1](1.2.2.1-bootstrapping-clusters-with-kubeadm/1.2.2.1.1-installing-kubeadm/README.md) on that node
- **Nodes stay `NotReady` after join** → install a CNI as in [1.2.2.1.3](1.2.2.1-bootstrapping-clusters-with-kubeadm/1.2.2.1.3-creating-a-cluster-with-kubeadm/README.md); confirm runtime socket from **1.2.1**
- **Unsure whether to build HA** → read [1.2.2.1.5](1.2.2.1-bootstrapping-clusters-with-kubeadm/1.2.2.1.5-options-for-highly-available-topology/README.md) before buying load balancers
- **Only evaluating EKS/GKE/AKS** → jump to [1.2.3](../1.2.3-turnkey-cloud-solutions/README.md) while skimming kubeadm for vocabulary
- **`kubectl` points at the wrong cluster** → `kubectl config current-context` before any `kubeadm`-adjacent debugging

---

## Learning objective

- Stated the role of `kubeadm` and the ordering of **1.2.2.1.x** lessons.
- Located **1.2.3** as the managed-Kubernetes counterpart to self-built control planes.
- Ran the module wrap commands below when a lab cluster exists.

## Why this matters

Production-style clusters are upgraded and repaired file-by-file. Knowing the kubeadm sequence turns “random init flags” into a repeatable runbook.

## Video close — fast validation

**What happens when you run this:**

Prints kubeadm and kubectl client info, current context, nodes, and the first ~20 `kube-system` pods — read-only. `kubeadm version` may fail on a laptop with only `kubectl`; that is fine.

**Say:**

After the lessons I actually ran, I still expect a sane context, Ready nodes, and calm `kube-system` pods before I call Part 1.2.2 done.

**Run:**

```bash
kubeadm version 2>/dev/null || true
kubectl version --client
kubectl config current-context
kubectl get nodes -o wide
kubectl get pods -n kube-system -o wide | head -n 20
```

**Expected:**

Client versions print; context matches your lab; nodes `Ready` when a cluster exists; system pods mostly `Running`.

For **1.2.3** alone (managed path), also run `bash "$COURSE_DIR/part-1-getting-started/1.2-production-environment/1.2.3-turnkey-cloud-solutions/scripts/cloud-readiness-check.sh"`.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `1.2.2.1-bootstrapping-clusters-with-kubeadm/` | Full kubeadm lesson chain |
| `../1.2.3-turnkey-cloud-solutions/` | Managed Kubernetes decision + CLI check |

---

## Sections

### 1.2.2.1 Bootstrapping Clusters with kubeadm

Install packages, diagnose failures, `kubeadm init` / `join`, customise components, design HA, join extra control planes, optional external etcd, kubelet config, dual-stack — see [1.2.2.1 README](1.2.2.1-bootstrapping-clusters-with-kubeadm/README.md).

---

## Next

Open [1.2.2.1 Bootstrapping clusters with kubeadm](1.2.2.1-bootstrapping-clusters-with-kubeadm/README.md), or [1.2.3 Turnkey cloud solutions](../1.2.3-turnkey-cloud-solutions/README.md) if you are choosing managed Kubernetes first.
