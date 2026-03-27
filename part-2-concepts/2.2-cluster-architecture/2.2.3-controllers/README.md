# 2.2.3 Controllers

- Summary: Controllers are the reconciliation engines of Kubernetes and the reason desired state becomes real state.
- Content: Teach watch loops, control theory basics, and why controllers never "finish" so much as continuously reconcile.
- Lab: Observe a controller react to a missing pod by restoring desired replica count.

## Assets

- `scripts/controller-reconciliation-demo.sh`
- `yamls/controller-demo-deployment.yaml`
