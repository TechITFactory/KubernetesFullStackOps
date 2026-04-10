# 2.1.2.5 Annotations

- Summary: Annotations store non-query metadata that tools and operators use for context, traceability, and behavior hints.
- Content: This subsection contrasts annotations with labels and shows common annotation-style metadata.
- Lab: Apply an annotated object and inspect its metadata.

## Assets

- `yamls/annotations-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/annotations-demo.yaml
kubectl get cm annotations-demo -n default -o jsonpath='{.metadata.annotations}' | head -c 200; echo
```

## Expected output

- ConfigMap `annotations-demo` in `default` shows custom annotations under `metadata.annotations`.

## Video close - fast validation

```bash
kubectl describe cm annotations-demo -n default | sed -n '/Annotations:/,/Data/p'
kubectl delete cm annotations-demo -n default --ignore-not-found
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common annotation size limits, confusing labels vs annotations, and tooling that ignores unknown keys.
