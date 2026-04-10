# 2.4.3.1 Deployments

- Summary: Deployments manage stateless rollout strategy, scaling, and rollback for ReplicaSets.
- Content: This is the default workload controller for stateless apps.
- Lab: Apply a Deployment and inspect rollout history.

## Assets

- `yamls/deployment-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/deployment-demo.yaml
kubectl rollout status deployment/deployment-demo --timeout=120s
kubectl get deploy,pods -l app=deployment-demo
```

## Expected output

- Deployment reaches available replicas; pods carry the expected label selector.

## Video close - fast validation

```bash
kubectl get deploy deployment-demo -o wide
kubectl rollout history deployment/deployment-demo
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common rollout, image, and selector failures.
