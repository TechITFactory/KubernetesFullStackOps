# 3.2.34 Running Kubernetes Node Components as a Non-root User

- Summary: Validate and harden node component runtime privileges.
- Content:
  - Running components with least privilege reduces risk.
  - Check service users and file permissions before changes.
  - Validate node health after privilege adjustments.
- Lab:

```bash
ps -eo user,pid,cmd | grep -E "kubelet|kube-proxy" | grep -v grep
sudo systemctl cat kubelet
sudo ls -ld /var/lib/kubelet /etc/kubernetes
kubectl get nodes
```

Success signal: components run with expected privileges and node remains ready.
Failure signal: kubelet fails due to permission or path access issues.

EKS extension: use hardened AMIs and managed security baselines.
