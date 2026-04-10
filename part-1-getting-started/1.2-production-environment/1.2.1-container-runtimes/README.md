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

You installed **one** runtime. Use **that** lesson’s unit name and socket (example below is **containerd**):

```bash
sudo systemctl is-active containerd
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock info
```

**CRI-O:** `crio`, socket `unix:///var/run/crio/crio.sock`.  
**cri-dockerd:** `docker` + `cri-docker`, socket `unix:///run/cri-dockerd.sock`.

Before **1.2.2 (kubeadm)**, you want **`active`** and **`crictl info`** without connection errors.
