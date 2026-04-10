# 2.3.3 Runtime Class

- Summary: RuntimeClass lets you choose different runtime handlers for pods when the node environment supports them.
- Content: Explain why RuntimeClass matters for sandboxed runtimes, performance profiles, and specialized execution environments.
- Lab: Review the RuntimeClass manifest and trace how a pod would reference it.

## Assets

- `yamls/runtimeclass-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/runtimeclass-demo.yaml
kubectl get runtimeclass
kubectl describe runtimeclass sandboxed-runtime
```

## Expected output

- `RuntimeClass` `sandboxed-runtime` exists with handler `sandboxed`.
- **Note:** Scheduling a pod with `runtimeClassName: sandboxed-runtime` requires a node/runtime that registers that handler; use this lesson to understand the API, not assume every cluster runs it.

## Video close - fast validation

```bash
kubectl get runtimeclass -o wide
kubectl get nodes -o wide
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common RuntimeClass handler mismatch and scheduling failures.
