# 1.2.2 Installing Kubernetes with Deployment Tools

## Overview

`kubeadm` is the official Kubernetes cluster bootstrapper. It handles control-plane initialisation, certificate generation, node joining, and configuration management — all from structured config files rather than ad hoc flags.

This section follows the full kubeadm lifecycle from package installation through high-availability cluster design.

- **Objective**: Bootstrap a kubeadm cluster from config files and understand every component it installs and manages.
- **Outcomes**: kubeadm, kubelet, and kubectl installed and version-pinned; control plane initialised; worker nodes joined; HA topology understood.
- **Note**: Complete 1.2.1 (container runtime) on all nodes before starting here.

## Sections

### 1.2.2.1 Bootstrapping Clusters with kubeadm
The complete kubeadm workflow: installing packages, initialising the control plane, joining nodes, customising the API, designing for high availability, managing external etcd, and configuring kubelet across the cluster.

## Module wrap — quick validation

After **1.2.2.1** plus **1.2.3** (read/decision), sanity-check tooling and cluster reachability:

```bash
kubeadm version
kubectl version --client
kubectl config current-context
kubectl get nodes -o wide
kubectl get pods -n kube-system -o wide | head -n 20
```

For **1.2.3** alone (managed path), also run the readiness script from that lesson: `../1.2.3-turnkey-cloud-solutions/scripts/cloud-readiness-check.sh`.
