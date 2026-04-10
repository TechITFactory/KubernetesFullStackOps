# 1.2.1 Container Runtimes

## Overview

Kubernetes does not run containers directly. It delegates that work to a **container runtime** installed on each node. The runtime must implement the **Container Runtime Interface (CRI)** — the standard API Kubernetes uses to start, stop, and inspect containers.

Pick one runtime per node. All three options here are CRI-compliant and production-ready. The choice affects which socket path kubelet uses and which cgroup driver you configure — both of which must match your kubeadm settings.

- **Objective**: Install a CRI-compatible runtime on all candidate nodes before running `kubeadm init` or `kubeadm join`.
- **Outcomes**: Runtime service running, CRI socket path confirmed, kubeadm node config ready with the correct socket reference.
- **Note**: Sections 1.2.1.1, 1.2.1.2, and 1.2.1.3 are alternatives — install only one per node. `containerd` is the recommended default for new clusters.

## Sections

### 1.2.1.1 containerd
The most widely deployed production runtime. Ships with every major cloud provider's managed Kubernetes offering and is the kubeadm default. Requires enabling the CRI plugin and setting `SystemdCgroup = true`.

### 1.2.1.2 CRI-O
Purpose-built for Kubernetes — no daemon overhead beyond what CRI requires. Preferred in Red Hat / OpenShift environments. Tracks Kubernetes minor versions directly.

### 1.2.1.3 Docker Engine (via cri-dockerd)
Docker Engine was removed as a native Kubernetes runtime in v1.24. `cri-dockerd` is a shim that bridges Docker back into CRI. Use this only for nodes with an existing Docker dependency — not recommended for new clusters.

## Module wrap — quick validation

You installed **one** runtime per node. Confirm the daemon is active and the CRI endpoint answers (socket paths are in your lesson — **1.2.1.1** containerd shown here):

```bash
sudo systemctl is-active containerd
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock info
```

If you followed **CRI-O** or **cri-dockerd**, use that lesson’s `systemctl` unit names and `crictl --runtime-endpoint` socket instead. Before **1.2.2**, you want `active` and `crictl info` JSON without connection errors.
