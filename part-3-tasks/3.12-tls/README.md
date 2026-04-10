# 3.12 TLS

- Objective: Apply practical TLS workflows for secure Kubernetes communication.
- Outcomes:
  - Issue client certificates with CSR flow.
  - Manage and rotate cluster certificates safely.
  - Validate certificate status and expiry in operations.
- Notes:
  - Keep certificate handling procedural and auditable.
  - Test in non-production before rotating trust roots.
  - Linux commands only.

## Children

- 3.12.1 Issue a Certificate for a Kubernetes API Client Using A CertificateSigningRequest
- 3.12.2 Configure Certificate Rotation for the Kubelet
- 3.12.3 Manage TLS Certificates in a Cluster
- 3.12.4 Manual Rotation of CA Certificates

## TLS Baseline Checks

```bash
kubectl get csr
sudo kubeadm certs check-expiration
kubectl get secrets -n kube-system | grep -i tls
```
