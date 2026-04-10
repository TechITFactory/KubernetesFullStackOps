# 2.2 Cluster Architecture

- Objective: Understand how Kubernetes nodes, control-plane services, and reconciliation loops work together under real operational conditions.
- Outcomes: Explain node responsibilities, control-plane communication paths, controller behavior, leases, cloud integration, and cluster self-healing patterns.
- Notes: This module is best taught by connecting architecture concepts directly to observable cluster behavior with `kubectl` and runtime signals.

## Children

- 2.2.1 Nodes
- 2.2.2 Communication between Nodes and the Control Plane
- 2.2.3 Controllers
- 2.2.4 Leases
- 2.2.5 Cloud Controller Manager
- 2.2.6 About cgroup v2
- 2.2.7 Kubernetes Self-Healing
- 2.2.8 Garbage Collection
- 2.2.9 Mixed Version Proxy

## Module wrap - quick validation

```bash
kubectl get nodes -o wide
kubectl get lease -n kube-node-lease
kubectl get pods -n kube-system -o wide
kubectl get events -A --sort-by=.lastTimestamp | tail -n 30
```
