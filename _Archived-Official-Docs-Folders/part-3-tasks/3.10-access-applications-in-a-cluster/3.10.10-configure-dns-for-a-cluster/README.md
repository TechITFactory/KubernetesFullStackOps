# 3.10.10 Configure DNS for a Cluster

- Summary: Configure and validate cluster DNS settings for reliable name resolution.
- Content:
  - DNS config impacts service discovery and app connectivity.
  - Validate from pod context, not from host only.
  - Keep CoreDNS config changes controlled and reversible.
- Lab:

```bash
kubectl -n kube-system get configmap coredns -o yaml
kubectl run dns-check --image=busybox:1.36 -it --rm --restart=Never -- nslookup kubernetes.default.svc.cluster.local
kubectl run dns-check2 --image=busybox:1.36 -it --rm --restart=Never -- nslookup kube-dns.kube-system.svc.cluster.local
kubectl -n kube-system logs deploy/coredns --tail=80
```

Success signal: both lookups resolve expected cluster IPs.
Failure signal: lookup timeout or CoreDNS error spikes.

EKS extension: validate Route53/private DNS interactions when using custom domains.
