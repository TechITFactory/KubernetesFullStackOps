# 2.4.1.2 Init Containers

- Summary: Init containers run to completion before app containers and are ideal for setup and dependency preparation.
- Content: Show ordering guarantees and failure behavior.
- Lab: Apply the init container example and inspect startup order.

## Assets

- `yamls/init-containers-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/init-containers-demo.yaml
kubectl wait --for=condition=Ready pod/init-containers-demo --timeout=120s
kubectl logs pod/init-containers-demo --all-containers=true --tail=30
```

## Expected output

- Init container(s) complete before the main container stays `Running`.

## Video close - fast validation

```bash
kubectl get pod init-containers-demo -o jsonpath='{.status.initContainerStatuses[*].state}{"\n"}'
kubectl describe pod init-containers-demo | sed -n '/Init Containers:/,/Containers:/p'
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common init container ordering, image pull, and retry failures.
