# 2.1.2.8 Owners and Dependents

- Summary: Owner references define garbage-collection relationships and help Kubernetes understand what should be cleaned up together.
- Content: This subsection explains how Deployments own ReplicaSets, ReplicaSets own Pods, and how cascading deletion works.
- Lab: Apply the sample Deployment, inspect owner references, then delete the parent object.

## Assets

- `scripts/show-owner-references.sh`
- `yamls/owner-reference-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/owner-reference-demo.yaml
kubectl wait --for=condition=available deployment/owner-demo -n owner-demo --timeout=120s
./scripts/show-owner-references.sh
```

## Expected output

- ReplicaSet and Pods in `owner-demo` show `ownerReferences` pointing up to the Deployment (and RS for Pods).

## Video close - fast validation

```bash
kubectl get rs,pods -n owner-demo -o custom-columns=KIND:.kind,NAME:.metadata.name,OWNER:.metadata.ownerReferences[*].name 2>/dev/null | head -n 15
kubectl delete -f yamls/owner-reference-demo.yaml --ignore-not-found
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common orphan resources, unexpected cascading deletes, and garbage collection timing.
