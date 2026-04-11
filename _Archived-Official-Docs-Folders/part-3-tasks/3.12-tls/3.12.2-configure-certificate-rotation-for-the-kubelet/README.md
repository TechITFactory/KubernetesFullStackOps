# 3.12.2 Configure Certificate Rotation for the Kubelet

- Summary: Enable and verify kubelet client certificate rotation.
- Content:
  - Rotation reduces risk of expired node client certs.
  - kubelet must be configured to rotate certificates automatically.
  - Validate CSR creation/approval and kubelet health.
- Lab:

```bash
sudo grep -i rotateCertificates /var/lib/kubelet/config.yaml
kubectl get csr
kubectl get nodes
sudo systemctl restart kubelet
kubectl get csr --watch
```

Success signal: new kubelet CSR appears and node remains Ready.
Failure signal: node becomes NotReady or CSR not approved.

EKS extension: managed nodes handle cert lifecycle differently; still monitor node auth health.
