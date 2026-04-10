# 2.3.4 Container Lifecycle Hooks

- Summary: Lifecycle hooks let containers run actions at specific startup or termination moments, but they must be used with intent.
- Content: Teach `postStart`, `preStop`, graceful termination, and the relationship between hooks and termination signals.
- Lab: Apply the lifecycle hook demo and inspect termination behavior.

## Assets

- `yamls/lifecycle-hooks-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/lifecycle-hooks-demo.yaml
kubectl wait --for=condition=Ready pod/lifecycle-hooks-demo --timeout=120s
kubectl exec pod/lifecycle-hooks-demo -c app -- cat /tmp/postStart-ran 2>/dev/null || true
```

## Expected output

- Pod becomes `Ready`; `postStart` wrote `/tmp/postStart-ran` inside the `app` container (verify with `kubectl exec`).

## Video close - fast validation

```bash
kubectl get pod lifecycle-hooks-demo -o wide
kubectl describe pod lifecycle-hooks-demo | sed -n '/Conditions:/,/Events:/p'
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common hook failures, grace period, and termination edge cases.
