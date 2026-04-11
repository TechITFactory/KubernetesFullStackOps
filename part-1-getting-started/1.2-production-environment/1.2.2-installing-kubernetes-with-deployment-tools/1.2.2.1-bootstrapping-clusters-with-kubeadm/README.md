# 1.2.2.1 Bootstrapping Clusters with kubeadm

## Intro

`kubeadm` is not a full distribution — it is the tool that wires API server, etcd, scheduler, controller-manager, and kubelet into a working cluster from config you control. This subsection follows the real-world order: install, diagnose, initialise, customise, plan HA, join HA nodes, optionally externalise etcd, align kubelet settings, then consider dual-stack **before** `kubeadm init`.

**Prerequisites:** [1.2.1 Container runtimes](../../1.2.1-container-runtimes/README.md) complete on every node; Linux nodes with `sudo`.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/part-1-getting-started/1.2-production-environment/1.2.2-installing-kubernetes-with-deployment-tools/1.2.2.1-bootstrapping-clusters-with-kubeadm"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  1.2.2.1.1 install  →  1.2.2.1.2 triage  →  1.2.2.1.3 init/join
         │                      │                    │
         │                      │                    ▼
         │                      │             1.2.2.1.4 customise
         │                      │                    │
         ▼                      ▼                    ▼
  1.2.2.1.5 HA options    (parallel read)     1.2.2.1.6 HA join
         │                                        │
         ▼                                        ▼
  1.2.2.1.7 external etcd (optional)      1.2.2.1.8 kubelet config
         │                                        │
         └────────────────┬───────────────────────┘
                          ▼
                   1.2.2.1.9 dual-stack plan
```

**Say:**

We install and pin packages first, learn to capture evidence before changing anything, bring up a first control plane and workers, then deepen into API customisation and HA. External etcd and dual-stack are branches you take only when architecture demands them.

---

## Step 1 — Open the kubeadm subsection folder

**What happens when you run this:**

`cd` lands in `1.2.2.1-bootstrapping-clusters-with-kubeadm`. `pwd` confirms.

**Say:**

Every child lesson’s scripts live under numbered folders here; I keep the shell here when narrating relative paths.

**Run:**

```bash
cd "$COURSE_DIR/part-1-getting-started/1.2-production-environment/1.2.2-installing-kubernetes-with-deployment-tools/1.2.2.1-bootstrapping-clusters-with-kubeadm"
pwd
```

**Expected:**

Path ending with `1.2.2.1-bootstrapping-clusters-with-kubeadm`.

---

## Step 2 — Start at 1.2.2.1.1 (reading step)

**What happens when you run this:**

You open [1.2.2.1.1 Installing kubeadm](1.2.2.1.1-installing-kubeadm/README.md) and run it on **each** node that will run kubelet.

**Say:**

Version skew between control plane and workers breaks upgrades; pinning starts in **1.2.2.1.1** with `apt-mark hold` (or your distro’s equivalent workflow).

**Run:**

_(Begin [1.2.2.1.1](1.2.2.1.1-installing-kubeadm/README.md).)_

**Expected:**

`kubeadm version`, `kubelet --version`, and `kubectl version --client` succeed on targeted nodes.

---

## Troubleshooting

- **Skipped runtime lesson** → kubelet cannot start pods; return to [1.2.1](../../1.2.1-container-runtimes/README.md)
- **`kubeadm init` fails immediately** → run [1.2.2.1.2](1.2.2.1.2-troubleshooting-kubeadm/README.md) **before** retrying init
- **Single laptop only** → read [1.2.2.1.5](1.2.2.1.5-options-for-highly-available-topology/README.md) for theory; skip **1.2.2.1.6**–**1.2.2.1.7** labs unless you have VMs
- **Dual-stack confusion mid-cluster** → read [1.2.2.1.9](1.2.2.1.9-dual-stack-support-with-kubeadm/README.md) **before** changing service or pod CIDRs
- **Lost join command** → re-print with the script from [1.2.2.1.3](1.2.2.1.3-creating-a-cluster-with-kubeadm/README.md)

---

## Learning objective

- Described the kubeadm subsection ordering and which lessons are optional for small labs.
- Navigated child README paths from `$COURSE_DIR` without mixing Part 1.1 local clusters with kubeadm nodes by mistake.
- Ran the wrap commands when a kubeadm cluster exists.

## Why this matters

Teams that treat kubeadm as “one magic command” miss certificates, static pods, and upgrade order. Walking the numbered lessons mirrors how platform engineers actually bootstrap.

## Video close — fast validation

**What happens when you run this:**

Cluster reachability snapshot: `cluster-info`, nodes, `kube-system` pods, and the default `kubernetes` Service. Optional dual-stack line prints Service `clusterIPs` when the API exposes it.

**Say:**

This is the same check I run after any init or join: API up, nodes Ready, system plane calm, Service row sane.

**Run:**

```bash
kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods -n kube-system -o wide | head -n 25
kubectl get svc kubernetes -o wide
kubectl get svc kubernetes -o jsonpath='{.spec.clusterIPs}{"\n"}' 2>/dev/null || true
```

**Expected:**

`cluster-info` URL; nodes listed; pods mostly `Running`; `kubernetes` Service shows `CLUSTER-IP` (or dual IPs when configured).

---

## Repo files (reference)

| Lesson | Path |
|--------|------|
| 1.2.2.1.1 | [installing-kubeadm](1.2.2.1.1-installing-kubeadm/README.md) |
| 1.2.2.1.2 | [troubleshooting-kubeadm](1.2.2.1.2-troubleshooting-kubeadm/README.md) |
| 1.2.2.1.3 | [creating-a-cluster-with-kubeadm](1.2.2.1.3-creating-a-cluster-with-kubeadm/README.md) |
| 1.2.2.1.4 | [customizing-components-with-the-kubeadm-api](1.2.2.1.4-customizing-components-with-the-kubeadm-api/README.md) |
| 1.2.2.1.5 | [options-for-highly-available-topology](1.2.2.1.5-options-for-highly-available-topology/README.md) |
| 1.2.2.1.6 | [creating-highly-available-clusters-with-kubeadm](1.2.2.1.6-creating-highly-available-clusters-with-kubeadm/README.md) |
| 1.2.2.1.7 | [ha-etcd-with-kubeadm](1.2.2.1.7-ha-etcd-with-kubeadm/README.md) |
| 1.2.2.1.8 | [kubelet-config-using-kubeadm](1.2.2.1.8-kubelet-config-using-kubeadm/README.md) |
| 1.2.2.1.9 | [dual-stack-support-with-kubeadm](1.2.2.1.9-dual-stack-support-with-kubeadm/README.md) |

---

## Children (work in order)

1. [1.2.2.1.1 Installing kubeadm](1.2.2.1.1-installing-kubeadm/README.md)
2. [1.2.2.1.2 Troubleshooting kubeadm](1.2.2.1.2-troubleshooting-kubeadm/README.md)
3. [1.2.2.1.3 Creating a cluster with kubeadm](1.2.2.1.3-creating-a-cluster-with-kubeadm/README.md)
4. [1.2.2.1.4 Customizing components with the kubeadm API](1.2.2.1.4-customizing-components-with-the-kubeadm-api/README.md)
5. [1.2.2.1.5 Options for highly available topology](1.2.2.1.5-options-for-highly-available-topology/README.md)
6. [1.2.2.1.6 Creating highly available clusters with kubeadm](1.2.2.1.6-creating-highly-available-clusters-with-kubeadm/README.md)
7. [1.2.2.1.7 Set up a high availability etcd cluster with kubeadm](1.2.2.1.7-ha-etcd-with-kubeadm/README.md)
8. [1.2.2.1.8 Configuring each kubelet in your cluster using kubeadm](1.2.2.1.8-kubelet-config-using-kubeadm/README.md)
9. [1.2.2.1.9 Dual-stack support with kubeadm](1.2.2.1.9-dual-stack-support-with-kubeadm/README.md)

---

## Next

Begin [1.2.2.1.1 Installing kubeadm](1.2.2.1.1-installing-kubeadm/README.md), or return to [1.2.2 parent](../README.md) / [1.2.3 Turnkey cloud](../../1.2.3-turnkey-cloud-solutions/README.md).
