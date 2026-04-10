# Part 1: GETTING STARTED

**Prerequisites:** Complete [Phase 1 — Prerequisites](../part-0-prerequisites/README.md) (Linux basics, then Docker basics) before this part unless you already have that background.

Hands-on path: **1.1** (local cluster + `dev-local` workspace) → **1.2** (production-style runtime + kubeadm + cloud trade-offs) → **1.3** (operational habits: scale, zones, nodes, security, PKI).

## Modules

- [1.1 Learning Environment](1.1-learning-environment/README.md) — Minikube *or* Kind, then governed `dev-local` namespace.
- [1.2 Production Environment](1.2-production-environment/README.md) — CRI runtime, kubeadm lifecycle, managed Kubernetes.
- [1.3 Best Practices](1.3-best-practices/README.md) — Pre-scale checks, multi-zone, validation, PSS, PKI.

## Part wrap — quick validation

When you finish Part 1, you should still have a reachable API and sane cluster state (local or lab kubeadm):

```bash
kubectl config current-context
kubectl get nodes -o wide
kubectl get pods -A | head -n 25
kubectl cluster-info
```

Green lights: context is the cluster you expect, all nodes `Ready`, `kube-system` (and your `dev-local` workloads if you use 1.1.3) are not crash-looping, and `cluster-info` returns a URL for the control plane.
