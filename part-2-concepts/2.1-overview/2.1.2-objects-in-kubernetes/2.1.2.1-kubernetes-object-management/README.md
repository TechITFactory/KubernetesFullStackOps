# 2.1.2.1 Kubernetes Object Management

- Summary: Object management is about reconciling desired state safely, not just creating YAML files.
- Content: This subsection demonstrates create/apply/delete flows and why declarative management is usually the better long-term approach.
- Lab: Apply a Deployment, modify it declaratively, and observe the live object state.

## Assets

- `scripts/object-management-demo.sh`
- `yamls/object-management-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
./scripts/object-management-demo.sh
kubectl get deploy,pods -n object-management-demo -o wide
```

## Expected output

- Namespace `object-management-demo` exists; Deployment `demo-nginx` reports available replicas and Pods are `Running`.

## Video close - fast validation

```bash
kubectl get deploy,pods -n object-management-demo
kubectl delete -f yamls/object-management-demo.yaml --ignore-not-found
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common apply conflicts, immutable fields, and stuck Terminating objects.
