# 3.2.1 Administration with kubeadm

- Summary: Perform essential kubeadm admin checks for control-plane health.
- Content:
  - kubeadm manages cluster bootstrap and upgrades.
  - Admin workflow: inspect config, certs, control-plane state.
  - Validate before and after any kubeadm operation.
- Lab:

```bash
sudo kubeadm config view
sudo kubeadm certs check-expiration
kubectl get nodes
kubectl get pods -n kube-system
kubectl cluster-info
```

Success signal: kube-system control-plane pods healthy and certs not near expiry.
Failure signal: expired certs or control-plane pod restarts.

EKS extension: kubeadm operations are for self-managed clusters; on EKS use managed upgrade workflows.
