# 3.2.35 Safely Drain a Node

- Summary: Drain nodes safely for maintenance without breaking workloads.
- Content:
  - `drain` evicts pods while respecting disruption budgets.
  - Cordon first, drain next, then verify workload rescheduling.
  - Uncordon after maintenance.
- Lab:

```bash
kubectl get nodes
kubectl cordon <node-name>
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
kubectl get pods -A -o wide
kubectl uncordon <node-name>
```

Success signal: workloads rescheduled and node returns `Ready,SchedulingEnabled`.
Failure signal: drain blocked by PDB or unmanaged pods.

EKS extension: use managed node group rolling updates with same pod-health checks.
