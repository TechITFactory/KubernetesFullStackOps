# 1.1 Learning Environment

## Overview

Before you can run a single `kubectl` command, you need a Kubernetes cluster to talk to. This module gets that cluster running on your laptop — no cloud account, no credit card, no waiting for infrastructure.

You will choose one of two local cluster tools (Minikube or Kind), get it running, then set up a governed development namespace you will reuse throughout the course.

- **Objective**: Set up a local Kubernetes cluster ready for every lab in this course.
- **Outcomes**: A running local cluster, `kubectl` connected and verified, and a baseline development namespace with resource controls in place.
- **Note**: Sections 1.1.1 and 1.1.2 are alternatives — pick one and stick with it. Section 1.1.3 runs on top of whichever you chose and must come after.

## Sections

### 1.1.1 Minikube Setup and Configuration
The most popular local Kubernetes tool. Runs a single-node cluster inside Docker or a VM on your laptop. Best choice if you want rich add-ons (Ingress, Dashboard) and a smooth developer experience.

### 1.1.2 Kind (Kubernetes in Docker)
Runs Kubernetes nodes as Docker containers. Supports multi-node clusters and starts in seconds. Best choice if you plan to use CI/CD pipelines or want to simulate a multi-node topology.

### 1.1.3 Local Development Clusters
Sets up a consistent, resource-governed development namespace (`dev-local`) on whichever cluster you just created. Covers Namespaces, ResourceQuotas, and LimitRanges — the three controls every production cluster uses to keep workloads isolated and safe.
