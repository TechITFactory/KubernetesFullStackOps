# 2.1.2.9 Recommended Labels

- Summary: Recommended labels make applications easier to operate, query, and understand across teams and tooling.
- Content: This subsection teaches the common `app.kubernetes.io/*` label set and why consistent metadata pays off over time.
- Lab: Apply the sample manifest and query objects by recommended labels.

## Assets

- `yamls/recommended-labels-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/recommended-labels-demo.yaml
kubectl wait --for=condition=available deployment/labels-demo --timeout=120s
kubectl get deploy labels-demo -n default --show-labels
kubectl get deploy -n default -l 'app.kubernetes.io/part-of=overview-module'
```

## Expected output

- Deployment carries `app.kubernetes.io/*` labels from the manifest; queries by `app.kubernetes.io/part-of` return `labels-demo`.

## Video close - fast validation

```bash
kubectl get deploy labels-demo -n default -o jsonpath='{range $k,$v := .metadata.labels}{$k}={$v}{"\n"}{end}' | grep app.kubernetes.io
kubectl delete -f yamls/recommended-labels-demo.yaml --ignore-not-found
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common inconsistent label keys, selector drift from labels, and tooling that expects recommended names.
