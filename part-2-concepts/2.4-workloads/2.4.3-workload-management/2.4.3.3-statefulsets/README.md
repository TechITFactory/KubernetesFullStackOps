# 2.4.3.3 StatefulSets

- Summary: StatefulSets provide stable identity and ordered rollout semantics for stateful workloads.
- Content: Highlight ordinal identity, stable network identity, and persistent storage patterns.
- Lab: Apply the StatefulSet example and inspect pod naming and volume claims.

## Assets

- `yamls/statefulset-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/statefulset-demo.yaml
kubectl rollout status statefulset/statefulset-demo --timeout=180s
kubectl get pods -l app=statefulset-demo
```

## Expected output

- Headless Service and StatefulSet reconcile; ordered pods reach `Running`.

## Video close - fast validation

```bash
kubectl get sts,svc statefulset-demo
kubectl get pods -l app=statefulset-demo -o wide
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common PVC, DNS, and ordered pod startup failures.
