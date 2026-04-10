# 3.12.4 Manual Rotation of CA Certificates

- Summary: Plan and execute manual CA rotation with minimal disruption.
- Content:
  - CA rotation is high-risk and requires phased rollout.
  - Always back up PKI material before changes.
  - Validate control-plane and kubelet trust after rotation.
- Lab:

```bash
sudo kubeadm certs check-expiration
sudo cp -r /etc/kubernetes/pki /etc/kubernetes/pki.backup.$(date +%F)
sudo kubeadm certs renew all
sudo systemctl restart kubelet
kubectl get nodes
kubectl get pods -n kube-system
```

Success signal: control-plane and nodes stay healthy post-renewal.
Failure signal: API server/kubelet trust errors after restart.

EKS extension: CA lifecycle for managed control plane is provider-managed; focus on workload/client cert rotation.
