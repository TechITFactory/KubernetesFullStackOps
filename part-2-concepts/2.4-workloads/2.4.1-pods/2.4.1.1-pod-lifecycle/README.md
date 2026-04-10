# 2.4.1.1 Pod Lifecycle

- Summary: Pods move through phases, conditions, and restart flows, but those signals should never be confused with application health by themselves.
- Content: Focus on phases, conditions, restarts, and readiness versus liveness.
- Lab: Create a demo pod and inspect phase and condition changes.

## Assets

- `yamls/pod-lifecycle-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/pod-lifecycle-demo.yaml
kubectl wait --for=condition=Ready pod/pod-lifecycle-demo --timeout=120s
kubectl get pod pod-lifecycle-demo -o wide
```

## Expected output

- Pod reaches `Running`; phase and conditions match the lesson narrative.

## Video close - fast validation

```bash
kubectl get pod pod-lifecycle-demo -o wide
kubectl describe pod pod-lifecycle-demo | sed -n '/Conditions:/,/Events:/p'
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common pod phase, probe, and scheduling failures.
