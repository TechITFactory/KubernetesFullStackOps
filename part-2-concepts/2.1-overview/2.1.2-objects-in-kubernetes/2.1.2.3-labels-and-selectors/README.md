# 2.1.2.3 Labels and Selectors

- Summary: Labels are queryable metadata, and selectors are the backbone of grouping, scheduling, and Service-to-Pod matching.
- Content: This subsection demonstrates equality-based selectors and the importance of stable app labels.
- Lab: Apply the sample Deployment and Service, then query objects with label selectors.

## Assets

- `scripts/query-label-selectors.sh`
- `yamls/labels-and-selectors-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/labels-and-selectors-demo.yaml
kubectl wait --for=condition=available deployment/demo-web --timeout=120s
./scripts/query-label-selectors.sh
```

## Expected output

- Deployment `demo-web` and Service `demo-web` in `default`; label queries return those objects.

## Video close - fast validation

```bash
kubectl get deploy,svc -n default -l app.kubernetes.io/part-of=overview-module
kubectl delete -f yamls/labels-and-selectors-demo.yaml --ignore-not-found
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common selector mismatches, set-based selector syntax errors, and Service target drift.
