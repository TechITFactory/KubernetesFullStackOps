# 1.2.1 Container Runtimes

## Overview

Kubernetes does **not** run containers itself. Each node runs a **CRI-compatible runtime** (Container Runtime Interface). kubelet talks to the runtime through a **Unix socket**; cgroup settings must match **systemd** on modern Linux.

**Pick one runtime per node.** Lessons **1.2.1.1**, **1.2.1.2**, and **1.2.1.3** are **alternatives** — same teaching layout (**Say → Run → Expected**), different packages and sockets.

| Lesson | Link | When to choose |
|--------|------|----------------|
| **1.2.1.1** | [containerd](1.2.1.1-containerd/README.md) | Default for new clusters; kubeadm / cloud-style paths. |
| **1.2.1.2** | [CRI-O](1.2.1.2-cri-o/README.md) | OpenShift / RHEL-style; tight K8s version alignment. |
| **1.2.1.3** | [Docker + cri-dockerd](1.2.1.3-docker-engine-via-cri-dockerd/README.md) | Legacy / migration only — not for greenfield. |

## Module wrap — quick validation

**What happens when you run this:**  
`systemctl is-active` reports whether the runtime daemon is running. `crictl info` calls the CRI API over the Unix socket — both are read-only. Run the block for **the runtime you installed**.

**containerd** (1.2.1.1):
```bash
sudo systemctl is-active containerd
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock info
```

**CRI-O** (1.2.1.2):
```bash
sudo systemctl is-active crio
sudo crictl --runtime-endpoint unix:///var/run/crio/crio.sock info
```

**Docker + cri-dockerd** (1.2.1.3):
```bash
sudo systemctl is-active docker
sudo systemctl is-active cri-docker
sudo crictl --runtime-endpoint unix:///run/cri-dockerd.sock info
```

**Expected for all three:** service reports `active`, `crictl info` returns JSON with no "connection refused" error.

Before **1.2.2 (kubeadm)**, you want both checks green. A missing socket or `inactive` daemon is why a fresh node stays `NotReady` after join.
