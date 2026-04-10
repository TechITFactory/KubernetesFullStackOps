# 2.4.3.2 ReplicaSet

- Summary: ReplicaSets keep a stable number of pods running but are usually managed through Deployments.
- Content: Teach ReplicaSets mainly as a controller that Deployments own.
- Lab: Inspect a Deployment-created ReplicaSet and compare selectors.

## Assets

- `yamls/replicaset-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/replicaset-demo.yaml
kubectl get rs replicaset-demo
kubectl get pods -l app=replicaset-demo
```

## Expected output

- ReplicaSet owns pods directly; desired vs ready counts match.

## Video close - fast validation

```bash
kubectl describe rs replicaset-demo | sed -n '/Replicas:/,/Pod Status:/p'
kubectl get pods -l app=replicaset-demo -o wide
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common selector overlap and orphan pod issues.
