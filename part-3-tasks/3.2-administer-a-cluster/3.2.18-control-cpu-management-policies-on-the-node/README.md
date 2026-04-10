# 3.2.18 Control CPU Management Policies on the Node

- Summary: Configure kubelet CPU manager policy for predictable CPU allocation.
- Content:
  - CPU manager static policy improves pinning for guaranteed workloads.
  - Node-level change requires careful rollout and validation.
  - Verify policy and pod CPU behavior after kubelet restart.
- Lab:

```bash
sudo grep -i cpuManagerPolicy /var/lib/kubelet/config.yaml
sudo sed -i 's/^cpuManagerPolicy:.*/cpuManagerPolicy: "static"/' /var/lib/kubelet/config.yaml
sudo systemctl restart kubelet
sudo systemctl status kubelet --no-pager
kubectl get nodes
```

Success signal: kubelet healthy and node ready with intended policy.
Failure signal: kubelet restart failure due to invalid config.

EKS extension: tune CPU behavior via supported node bootstrap/runtime options.
