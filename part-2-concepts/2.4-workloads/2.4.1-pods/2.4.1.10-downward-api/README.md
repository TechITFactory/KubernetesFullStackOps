# 2.4.1.10 Downward API

- Summary: The Downward API exposes pod and container metadata to workloads without hardcoding environment-specific values.
- Content: Teach both env-var and volume-based forms.
- Lab: Apply the demo pod and inspect the injected metadata.

## Assets

- `yamls/downward-api-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/downward-api-demo.yaml
kubectl wait --for=condition=Ready pod/downward-api-demo --timeout=120s
kubectl exec pod/downward-api-demo -c app -- printenv | grep -E '^POD_NAME=' || true
```

## Expected output

- Downward-injected metadata appears in env or volumes as defined in the manifest.

## Video close - fast validation

```bash
kubectl get pod downward-api-demo -o wide
kubectl describe pod downward-api-demo | sed -n '/Environment:/,/Mounts:/p'
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common fieldRef mistakes and missing metadata in projections.
