# 3.12.1 Issue a Certificate for a Kubernetes API Client Using A CertificateSigningRequest

- Summary: Issue a client certificate through Kubernetes CSR approval flow.
- Content:
  - CSR workflow is used for controlled cert issuance.
  - Approval should be explicit and audited.
  - Validate generated cert before client use.
- Lab:

```bash
openssl genrsa -out app-user.key 2048
openssl req -new -key app-user.key -out app-user.csr -subj "/CN=app-user/O=dev-team"
cat app-user.csr | base64 | tr -d '\n' > app-user.csr.b64
```

Create CSR resource:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: app-user-csr
spec:
  request: $(cat app-user.csr.b64)
  signerName: kubernetes.io/kube-apiserver-client
  usages:
    - client auth
EOF
kubectl get csr
kubectl certificate approve app-user-csr
kubectl get csr app-user-csr -o yaml
```

Success signal: CSR shows `Approved,Issued`.
Failure signal: CSR pending forever or wrong signer/usage.

EKS extension: use IAM authentication as primary path; CSR flow for specific self-managed needs.
