# 3.2.10 Autoscale the DNS Service in a Cluster

- Summary: Ensure DNS scales with cluster size and query load.
- Content:
  - CoreDNS must scale to avoid resolution bottlenecks.
  - Monitor DNS pod count and latency under load.
  - Use autoscaler or manual scaling with verification.
- Lab:

```bash
kubectl -n kube-system get deploy coredns
kubectl -n kube-system scale deploy coredns --replicas=3
kubectl -n kube-system rollout status deploy coredns
kubectl -n kube-system get pods -l k8s-app=kube-dns -o wide
```

Success signal: CoreDNS rollout completes and pods are healthy.
Failure signal: DNS lookups fail or CoreDNS pods crash/restart.

EKS extension: use EKS add-on CoreDNS settings and monitor with CloudWatch metrics.
