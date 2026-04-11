# 3.1.1 Install and Set Up kubectl on Linux

- Summary: Install `kubectl` on Linux and verify cluster connectivity.
- Content:
  - `kubectl` is the core operator CLI.
  - Verify binary integrity and executable permissions.
  - Validate context and API access immediately after install.
- Lab:

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
kubectl config get-contexts
```

Success signal: checksum OK and client version prints.
Failure signal: permission denied or checksum mismatch.

EKS extension: run `aws eks update-kubeconfig` then `kubectl get nodes`.
