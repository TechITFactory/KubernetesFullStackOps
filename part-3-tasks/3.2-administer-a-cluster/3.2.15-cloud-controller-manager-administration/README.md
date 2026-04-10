# 3.2.15 Cloud Controller Manager Administration

- Summary: Verify cloud controller manager health and cloud integration state.
- Content:
  - CCM manages cloud-specific node, route, and load balancer logic.
  - Misconfigured CCM causes node/provider sync issues.
  - Validate CCM pods, logs, and node cloud metadata.
- Lab:

```bash
kubectl -n kube-system get pods | grep -i cloud-controller
kubectl -n kube-system logs deploy/cloud-controller-manager --tail=80
kubectl get nodes -o wide
kubectl describe node <node-name> | grep -i providerID
```

Success signal: CCM components healthy and nodes show provider IDs.
Failure signal: cloud routes/LB/node sync errors in logs.

EKS extension: CCM behavior is mostly managed; validate via managed components and events.
