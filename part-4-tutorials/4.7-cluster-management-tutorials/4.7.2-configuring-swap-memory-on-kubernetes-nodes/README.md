# 4.7.2 Configuring Swap Memory on Kubernetes Nodes

- Summary: Inspect and configure swap behavior safely for Kubernetes nodes.
- Content:
  - Swap policy affects pod memory behavior and stability.
  - Validate kubelet and node settings together.
  - Apply changes gradually and verify workloads.
- Lab:

```bash
swapon --show
free -h
sudo grep -i swap /etc/fstab
sudo cat /var/lib/kubelet/config.yaml | grep -i failSwapOn
kubectl get nodes
```

Success signal: node health remains stable with intended swap policy.
Failure signal: kubelet refuses startup due to conflicting swap settings.

EKS extension: verify AMI defaults and kubelet args in node group bootstrap.
