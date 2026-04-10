# 3.2.45 Verify Signed Kubernetes Artifacts

- Summary: Verify integrity and signatures of Kubernetes release artifacts.
- Content:
  - Artifact signature checks reduce supply-chain risk.
  - Validate checksums before using binaries in clusters.
  - Keep verification steps in build/release workflows.
- Lab:

```bash
VERSION="<k8s-version>"
curl -LO "https://dl.k8s.io/release/${VERSION}/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/${VERSION}/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
```

Success signal: `kubectl: OK` checksum verification.
Failure signal: checksum mismatch.

EKS extension: verify all custom binaries/tools used in node bootstrap pipelines.
