# 1.2.2.1 Bootstrapping Clusters with kubeadm

## Overview

`kubeadm` is not a Kubernetes distribution — it is a tool that assembles the components (API server, controller-manager, scheduler, etcd, kubelet) into a working cluster according to a config file you provide. It is designed for repeatability: the same config file produces the same cluster every time.

This subsection walks the complete kubeadm lifecycle in the order you would perform it on a real cluster.

- **Objective**: Bootstrap a production-style Kubernetes cluster using config-driven kubeadm commands.
- **Outcomes**: Packages installed and pinned, control plane initialised, workers joined, HA topology chosen, kubelet configured consistently.
- **Note**: Work through these sections in order — each one builds on the previous.

## Sections

### 1.2.2.1.1 Installing kubeadm
Install `kubeadm`, `kubelet`, and `kubectl` from the official package repository and pin their versions to prevent accidental upgrades.

### 1.2.2.1.2 Troubleshooting kubeadm
Collect a full diagnostic bundle from a node before making any changes — kubelet logs, runtime status, swap state, ports, and preflight signals.

### 1.2.2.1.3 Creating a Cluster with kubeadm
Initialise the control plane from a config file, copy the admin kubeconfig, and generate the worker join command.

### 1.2.2.1.4 Customizing Components with the kubeadm API
Override default API server flags, controller-manager settings, kube-proxy mode, and feature gates through structured config files instead of command-line arguments.

### 1.2.2.1.5 Options for Highly Available Topology
Compare stacked etcd versus external etcd HA topologies and choose the right one based on operational capacity and failure-domain requirements.

### 1.2.2.1.6 Creating Highly Available Clusters with kubeadm
Initialise the first HA control-plane node with `--upload-certs` and join additional control-plane nodes behind a load balancer.

### 1.2.2.1.7 Set up a High Availability etcd Cluster with kubeadm
Plan and document the external etcd cluster — endpoints, peer URLs, PKI file paths — before pointing kubeadm at it.

### 1.2.2.1.8 Configuring each kubelet in your Cluster Using kubeadm
Apply a consistent `KubeletConfiguration` across all nodes through the kubeadm-managed drop-in directory.

### 1.2.2.1.9 Dual-stack Support with kubeadm
Design and initialise a cluster with both IPv4 and IPv6 pod and service CIDRs — decisions that must be made before `kubeadm init`, not after.
