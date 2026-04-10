# 2.1.2.10 Storage Versions

- Summary: Storage versions determine how objects are persisted in etcd and matter when APIs evolve across releases.
- Content: This subsection explains served versions versus storage versions and why storage-version migration exists.
- Lab: Review the notes manifest and trace one example resource across API version transitions.

## Assets

- `yamls/storage-version-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/storage-version-notes.yaml
kubectl get cm storage-version-notes -n kube-system -o jsonpath='{.data.notes}' | head -n 5
```

## Expected output

- ConfigMap `storage-version-notes` in `kube-system` contains the embedded explanation text (requires RBAC to create/update objects in `kube-system` on your cluster).

## Video close - fast validation

```bash
kubectl api-versions | head -n 20
kubectl get --raw /apis/apps/v1 2>/dev/null | head -c 120; echo
kubectl delete cm storage-version-notes -n kube-system --ignore-not-found
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common served vs stored version confusion, migration job failures, and deprecated API removals.
