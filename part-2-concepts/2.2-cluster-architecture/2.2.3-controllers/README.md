# 2.2.3 Controllers

- Summary: Controllers are the reconciliation engines of Kubernetes and the reason desired state becomes real state.
- Content: Teach watch loops, control theory basics, and why controllers never "finish" so much as continuously reconcile.
- Lab: Observe a controller react to a missing pod by restoring desired replica count.

## Assets

- `scripts/controller-reconciliation-demo.sh`
- `yamls/controller-demo-deployment.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
./scripts/controller-reconciliation-demo.sh
kubectl apply -f yamls/controller-demo-deployment.yaml
kubectl get deploy,pods -l app=controller-demo
```

## Expected output

- Deployment reaches desired replicas.
- Deleting a managed pod triggers controller reconciliation and pod recreation.

## Video close - fast validation

```bash
kubectl get deploy,pods -l app=controller-demo
kubectl describe deploy controller-demo | sed -n '1,80p'
kubectl get events --sort-by=.lastTimestamp | tail -n 20
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common reconciliation, selector, and rollout-state failures.
