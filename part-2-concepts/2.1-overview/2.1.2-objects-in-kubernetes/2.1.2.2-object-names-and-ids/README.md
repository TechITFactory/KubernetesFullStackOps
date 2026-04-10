# 2.1.2.2 Object Names and IDs

- Summary: Object names are human-facing identifiers; UIDs are immutable identity values used internally for object lifetime.
- Content: This subsection shows the difference between `metadata.name`, `generateName`, and `metadata.uid`.
- Lab: Create example objects and compare names versus UIDs.

## Assets

- `yamls/object-name-and-uid-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl create -f yamls/object-name-and-uid-demo.yaml
kubectl get cm -n default -l training.k8sops.io/lesson=object-names-and-ids -o custom-columns=NAME:.metadata.name,UID:.metadata.uid
```

## Expected output

- One ConfigMap whose `metadata.name` starts with `generated-object-` and a non-empty `metadata.uid`.

## Video close - fast validation

```bash
kubectl create -f yamls/object-name-and-uid-demo.yaml
kubectl get cm -n default -l training.k8sops.io/lesson=object-names-and-ids -o yaml | head -n 40
kubectl delete cm -n default -l training.k8sops.io/lesson=object-names-and-ids
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common `generateName` surprises, UID confusion, and invalid name characters.
