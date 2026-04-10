# 2.4.1.9 User Namespaces

- Summary: User namespaces remap container user IDs to improve isolation on supported runtimes and kernels.
- Content: Treat this as an advanced security and runtime capability topic.
- Lab: Review the notes manifest and map it to your runtime support.

## Assets

- `yamls/user-namespaces-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/user-namespaces-notes.yaml
kubectl get configmap user-namespaces-notes -n kube-system
```

## Expected output

- Notes ConfigMap is stored for comparing cluster/user namespace support and constraints.

## Video close - fast validation

```bash
kubectl version -o yaml | sed -n '1,25p'
kubectl get nodes -o wide
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common user namespace support gaps and pod security integration issues.
