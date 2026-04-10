# 4.7 Cluster Management Tutorials

- Objective: Build practical node and cluster operations skills for real environments.
- Outcomes:
  - Understand node-level behavior affecting workload stability.
  - Apply safe operational changes and validate cluster health.
  - Use namespaces and resource boundaries for multi-team operations.
- Notes:
  - Perform one change at a time, then validate.
  - Linux-first commands and checks.
  - Include EKS operational mapping where relevant.

## Children

- 4.7.1 Running Kubelet in Standalone Mode
- 4.7.2 Configuring Swap Memory on Kubernetes Nodes
- 4.7.3 Install Drivers and Allocate Devices with DRA
- 4.7.4 Namespaces Walkthrough

## Module Validation

```bash
kubectl get nodes -o wide
kubectl get ns
kubectl get events -A --sort-by=.lastTimestamp | tail -n 30
```
