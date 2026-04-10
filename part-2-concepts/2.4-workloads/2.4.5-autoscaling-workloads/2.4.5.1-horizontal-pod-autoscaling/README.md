# 2.4.5.1 Horizontal Pod Autoscaling

- Summary: HPA scales replica counts based on observed metrics and only works well when requests and metrics pipelines are correct.
- Content: Focus on target utilization, metrics-server dependency, and stabilization behavior.
- Lab: Review the HPA example and map it to required metrics inputs.

## Assets

- `yamls/hpa-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f ../../2.4.4-managing-workloads/yamls/manage-workloads-demo.yaml
kubectl rollout status deployment/manage-workloads-demo --timeout=120s
kubectl apply -f yamls/hpa-demo.yaml
kubectl get hpa hpa-demo
```

## Expected output

- HPA object exists and references `Deployment/manage-workloads-demo`.
- **Note:** CPU-based scaling needs metrics (for example `metrics-server` on Minikube: `minikube addons enable metrics-server`).

## Video close - fast validation

```bash
kubectl get hpa
kubectl describe hpa hpa-demo | sed -n '/Metrics:/,/Events:/p'
kubectl top pods 2>/dev/null || true
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common metrics-server gaps, target reference, and policy misconfiguration.
