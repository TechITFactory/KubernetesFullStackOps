# 2.4.1.4 Ephemeral Containers

- Summary: Ephemeral containers exist for debugging running pods and are not part of the original workload spec.
- Content: Focus on debug workflows and why ephemeral containers are not restartable app containers.
- Lab: Review the notes and practice adding an ephemeral container with `kubectl debug`.

## Assets

- `yamls/ephemeral-container-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/ephemeral-container-notes.yaml
kubectl get configmap ephemeral-container-notes -n kube-system
```

## Expected output

- Notes ConfigMap exists in `kube-system` for review during debugging workflows.

## Video close - fast validation

```bash
kubectl get cm ephemeral-container-notes -n kube-system -o yaml | sed -n '1,35p'
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common debug workflow and ephemeral container admission failures.
