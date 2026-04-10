# 1.2 Production Environment

## Overview

Local clusters (Minikube, Kind) are for learning. Production clusters are a different discipline — they run on real Linux servers, require a CRI-compatible container runtime on every node, and are bootstrapped with tools designed for repeatability and upgrade safety.

This module covers the full production setup path: choosing and installing a container runtime, bootstrapping a cluster with `kubeadm`, configuring high availability, and knowing when a managed cloud service is the better call.

- **Objective**: Build or evaluate a production-grade Kubernetes cluster from scratch using the official toolchain.
- **Outcomes**: Container runtime installed and CRI-verified, kubeadm cluster bootstrapped from config files, HA topology understood, managed services evaluated.
- **Note**: Complete 1.2.1 (runtime install) before 1.2.2 (kubeadm). Section 1.2.3 is independent and can be read at any point to inform your architecture decision.

## Sections

### 1.2.1 Container Runtimes
Every Kubernetes node needs a container runtime — the process that actually pulls images and starts containers. Kubernetes talks to runtimes through the Container Runtime Interface (CRI). This section installs one of three supported runtimes: `containerd`, `CRI-O`, or Docker Engine via `cri-dockerd`.

### 1.2.2 Installing Kubernetes with Deployment Tools
Covers `kubeadm` end to end: installing the packages, initialising a control plane from a config file, joining worker nodes, configuring HA, and managing kubelet settings across the cluster.

### 1.2.3 Turnkey Cloud Solutions
Evaluates managed Kubernetes offerings (EKS, GKE, AKS, and others) for teams where operating the control plane themselves is not the right trade-off.

## Module wrap — quick validation

After the runtime + kubeadm track you should have Linux nodes with a working CRI and (for the kubeadm labs) a healthy control plane:

```bash
kubectl get nodes -o wide
kubectl get pods -n kube-system -o wide | head -n 25
kubeadm version 2>/dev/null || true
kubectl version --client
```

If you only completed **1.2.1** (no cluster yet), skip `kubectl` and instead verify the runtime service and CRI socket from the lesson you followed (`crictl` against that socket, `systemctl status` on the daemon).
