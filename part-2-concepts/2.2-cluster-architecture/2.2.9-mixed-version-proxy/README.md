# 2.2.9 Mixed Version Proxy

- Summary: Mixed version proxy exists to smooth component-version interoperability during upgrade windows.
- Content: Treat this as an advanced architectural concept tied to skew policy, compatibility, and controlled upgrade strategy.
- Lab: Review the notes manifest and connect it to your broader cluster upgrade policy.

## Assets

- `yamls/mixed-version-proxy-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl version
kubectl get nodes -o wide
kubectl apply -f yamls/mixed-version-proxy-notes.yaml
```

## Expected output

- Control-plane/node versions are inspectable for skew awareness.
- Upgrade-policy notes apply cleanly and can be reviewed with live version output.

## Video close - fast validation

```bash
kubectl version
kubectl get nodes -o custom-columns=NAME:.metadata.name,KUBELET:.status.nodeInfo.kubeletVersion
kubectl get events -A --sort-by=.lastTimestamp | tail -n 20
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common version-skew and upgrade-window compatibility failures.
