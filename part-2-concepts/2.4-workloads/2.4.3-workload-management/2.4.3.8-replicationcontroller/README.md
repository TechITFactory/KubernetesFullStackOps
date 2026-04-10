# 2.4.3.8 ReplicationController

- Summary: ReplicationController is the older predecessor to ReplicaSet and mostly matters now for historical context.
- Content: Use it to explain Kubernetes evolution and why selectors improved over time.
- Lab: Compare the ReplicationController example with a ReplicaSet.

## Assets

- `yamls/replicationcontroller-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/replicationcontroller-demo.yaml
kubectl get rc rc-demo
kubectl get pods -l app=rc-demo
```

## Expected output

- ReplicationController maintains the declared replica count for its template.

## Video close - fast validation

```bash
kubectl describe rc rc-demo | sed -n '/Replicas:/,/Pod Status:/p'
kubectl get pods -l app=rc-demo -o wide
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common legacy RC pitfalls and migration issues to Deployments.
