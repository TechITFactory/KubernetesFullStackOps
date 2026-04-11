# 1.2 Production Environment

## Intro

Local clusters (Minikube, Kind) are for learning. Production clusters run on real Linux servers, require a CRI-compatible container runtime on every node, and are bootstrapped with tools designed for repeatability and upgrade safety.

This module covers the full production setup path: choosing and installing a container runtime, bootstrapping a cluster with `kubeadm`, configuring high availability, and knowing when a managed cloud service is the better call.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/part-1-getting-started/1.2-production-environment"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  Self-managed                        Alternative
  ──────────────────────────          ─────────────────────
  1.2.1 CRI on each node              1.2.3 EKS / GKE / AKS
           │                                   │
           ▼                                   │
  1.2.2 kubeadm init + join                    │
           │                                   │
           └──────────────┬────────────────────┘
                          ▼
              Your apps and kubectl
              (same Kubernetes API)
```

**Say:**

Two routes to production Kubernetes: you install the runtime and control plane yourself, or you buy a managed control plane. Both paths still end with the same API for apps and `kubectl`; the trade-off is how much of the control plane you operate.

---

## Step 1 — Open the 1.2 module folder

**What happens when you run this:**

`cd` moves into `1.2-production-environment`. `pwd` confirms the path.

**Say:**

I anchor here before opening **1.2.1**, **1.2.2**, or **1.2.3** so relative paths in the videos stay consistent.

**Run:**

```bash
cd "$COURSE_DIR/part-1-getting-started/1.2-production-environment"
pwd
```

**Expected:**

Path ending with `1.2-production-environment`.

---

## Step 2 — Choose your track (reading step)

**What happens when you run this:**

You read the section list and open the README that matches your lab — no commands unless that lesson says so.

**Say:**

Complete **1.2.1** before **1.2.2** when you build your own nodes. **1.2.3** stands alone for architecture decisions about managed offerings.

**Run:**

_(Open [1.2.1 Container runtimes](1.2.1-container-runtimes/README.md), [1.2.2 Installing Kubernetes with deployment tools](1.2.2-installing-kubernetes-with-deployment-tools/README.md), or [1.2.3 Turnkey cloud solutions](1.2.3-turnkey-cloud-solutions/README.md).)_

**Expected:**

You know whether you are studying runtime install, kubeadm lifecycle, or managed Kubernetes next.

---

## Troubleshooting

- **`kubectl` works but nodes never become Ready after join** → revisit **1.2.1** socket and cgroup checks before chasing CNI issues
- **Unclear ordering between 1.2.1 and 1.2.2** → always install and verify the CRI on each node before `kubeadm init` / `join`
- **No Linux nodes available** → stay on Part **1.1** until you have VMs or bare metal; read **1.2.3** for managed options in parallel
- **`kubeadm` commands not found on the node** → complete the package install lessons under **1.2.2** on that OS
- **Only need conceptual cloud comparison** → read **1.2.3** without running kubeadm

---

## Learning objective

- Stated the difference between self-managed and managed control planes while recognizing the same Kubernetes API surface.
- Chose whether **1.2.1** and **1.2.2** apply to the learner’s environment.
- Located **1.2.3** for evaluating EKS, GKE, AKS, and similar services.

## Why this matters

Production incidents often trace to skipped prerequisites — wrong runtime socket, cgroup mismatch, or missing upgrade story. This module is the checklist teams run before declaring a cluster production-ready.

## Video close — fast validation

**What happens when you run this:**

After the runtime plus kubeadm track you should see healthy nodes and stable system pods. If you only finished **1.2.1**, run the runtime checks from that lesson instead of `kubectl`.

**Say:**

When I have a full cluster I glance at nodes and `kube-system`; when I only configured runtimes I use `systemctl` and `crictl` from the runtime lesson.

**Run:**

```bash
kubectl get nodes -o wide
kubectl get pods -n kube-system -o wide | head -n 25
kubeadm version 2>/dev/null || true
kubectl version --client
```

**Expected:**

Nodes `Ready` when a cluster exists; `kube-system` pods mostly `Running`; client version prints; `kubeadm version` prints on nodes where kubeadm is installed.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `1.2.1-container-runtimes/` | containerd, CRI-O, or cri-dockerd labs |
| `1.2.2-installing-kubernetes-with-deployment-tools/` | kubeadm lifecycle lessons |
| `1.2.3-turnkey-cloud-solutions/README.md` | Managed Kubernetes trade-offs |

---

## Sections

### 1.2.1 Container Runtimes

Every Kubernetes node needs a container runtime — the process that actually pulls images and starts containers. Kubernetes talks to runtimes through the Container Runtime Interface (CRI). This section installs one of three supported runtimes: `containerd`, `CRI-O`, or Docker Engine via `cri-dockerd`.

### 1.2.2 Installing Kubernetes with Deployment Tools

Covers `kubeadm` end to end: installing the packages, initialising a control plane from a config file, joining worker nodes, configuring HA, and managing kubelet settings across the cluster.

### 1.2.3 Turnkey Cloud Solutions

Evaluates managed Kubernetes offerings (EKS, GKE, AKS, and others) for teams where operating the control plane themselves is not the right trade-off.

---

## Next

Continue with [1.3 Best practices](../1.3-best-practices/README.md) after your cluster path is stable, or jump to [Part 2 Concepts](../../part-2-concepts/README.md) if your syllabus sends you there first.
