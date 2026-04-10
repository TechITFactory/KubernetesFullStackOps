# 2.4.1.3 Sidecar Containers

- Summary: Sidecars add helper behavior to a pod such as proxying, logging, or config reloading.
- Content: Teach sidecars as tightly coupled helpers sharing the same pod lifecycle boundary.
- Lab: Deploy a main container plus helper sidecar.

## Assets

- `yamls/sidecar-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/sidecar-demo.yaml
kubectl wait --for=condition=Ready pod/sidecar-demo --timeout=120s
kubectl get pod sidecar-demo -o jsonpath='{.spec.containers[*].name}{"\n"}'
```

## Expected output

- Pod is `Ready` with multiple containers running (sidecar pattern visible in spec).

## Video close - fast validation

```bash
kubectl get pod sidecar-demo -o wide
kubectl logs sidecar-demo --all-containers=true --tail=20
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common multi-container startup, shared volume, and probe failures.
