# 3.2.21 Customizing DNS Service

- Summary: Customize CoreDNS behavior for cluster-specific name resolution needs.
- Content:
  - CoreDNS config controls forwarding and custom zone behavior.
  - ConfigMap edits must be validated with live lookups.
  - Restart rollout only after config syntax check.
- Lab:

```bash
kubectl -n kube-system get configmap coredns -o yaml > coredns.yaml
kubectl -n kube-system edit configmap coredns
kubectl -n kube-system rollout restart deploy coredns
kubectl -n kube-system rollout status deploy coredns
kubectl -n kube-system get configmap coredns -o yaml
```

Success signal: CoreDNS pods restart healthy and DNS queries continue working.
Failure signal: CoreDNS CrashLoopBackOff after config change.

EKS extension: CoreDNS is managed as add-on; persist customizations carefully during upgrades.
