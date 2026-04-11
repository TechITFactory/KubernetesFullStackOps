# 3.2.22 Debugging DNS Resolution

- Summary: Diagnose DNS failures from pod-level and cluster-level signals.
- Content:
  - DNS issues often come from CoreDNS, service definitions, or network policy.
  - Test from inside a pod to isolate resolver behavior.
  - Correlate CoreDNS logs with failing queries.
- Lab:

```bash
kubectl run dns-test --image=busybox:1.36 -it --rm --restart=Never -- nslookup kubernetes.default
kubectl get svc -A
kubectl -n kube-system get pods -l k8s-app=kube-dns
kubectl -n kube-system logs deploy/coredns --tail=100
kubectl get events -A --sort-by=.lastTimestamp | tail -n 30
```

Success signal: `nslookup kubernetes.default` resolves cluster IP.
Failure signal: lookup timeout or SERVFAIL/NXDOMAIN for known service names.

EKS extension: include VPC DNS and security group checks when debugging resolution.
