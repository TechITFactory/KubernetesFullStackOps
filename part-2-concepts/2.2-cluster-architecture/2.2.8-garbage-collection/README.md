# 2.2.8 Garbage Collection

- Summary: Garbage collection in Kubernetes depends on owner references, cascading deletion, and API lifecycle semantics.
- Content: Teach how dependents are cleaned up and why orphaned resources happen when ownership metadata is missing or changed.
- Lab: Create an owned resource and observe cascading cleanup.

## Assets

- `scripts/garbage-collection-demo.sh`
- `yamls/garbage-collection-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
./scripts/garbage-collection-demo.sh
kubectl apply -f yamls/garbage-collection-demo.yaml
kubectl get all -l app=gc-demo
```

## Expected output

- Owner/dependent relationships are observable in object metadata.
- Cascading delete removes dependents when owner references are correct.

## Video close - fast validation

```bash
kubectl get all -l app=gc-demo
kubectl get events --sort-by=.lastTimestamp | tail -n 20
kubectl api-resources | grep -E '^replicasets|^deployments|^pods' || true
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common orphaned-resource, ownerRef, and cascade-deletion failures.
