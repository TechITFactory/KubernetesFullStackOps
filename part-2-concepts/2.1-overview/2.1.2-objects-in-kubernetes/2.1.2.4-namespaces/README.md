# 2.1.2.4 Namespaces

- Summary: Namespaces provide a first-level partitioning boundary for names, policy, quotas, and access control.
- Content: This subsection demonstrates namespace creation, scoping, and why `default` should not be your long-term home for everything.
- Lab: Apply the namespace manifest and deploy a namespaced object into it.

## Assets

- `yamls/namespace-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/namespace-demo.yaml
kubectl get ns overview-lab --show-labels
```

## Expected output

- Namespace `overview-lab` exists with label `purpose=training`.

## Video close - fast validation

```bash
kubectl get ns overview-lab -o yaml | head -n 30
kubectl delete ns overview-lab --ignore-not-found
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common context/namespace scoping mistakes, finalizer stuck namespaces, and RBAC denials.
