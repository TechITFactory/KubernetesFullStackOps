# 4.7.1 Running Kubelet in Standalone Mode

- Summary: Understand standalone kubelet mode and verify node-level behavior safely.
- Content:
  - Standalone mode is mainly for diagnostics and special setups.
  - Most production clusters use API-server connected kubelet mode.
  - Validate kubelet status and config before making changes.
- Lab:

```bash
sudo systemctl status kubelet --no-pager
ps -ef | grep kubelet
sudo cat /var/lib/kubelet/config.yaml | sed -n '1,80p'
kubectl get nodes -o wide
```

Success signal: kubelet active and node remains `Ready`.
Failure signal: kubelet crash loops or node turns `NotReady`.

EKS extension: direct kubelet config edits are limited; use managed node group patterns.
