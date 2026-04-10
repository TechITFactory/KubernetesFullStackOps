# 2.1.3 The Kubernetes API

- Summary: The Kubernetes API is the cluster’s source of truth and the only supported way to read or change desired state.
- Content: This section introduces discovery, API groups, verbs, versioning, raw endpoint access, and the relationship between the API server and controllers.
- Lab: Use `kubectl proxy` and raw API queries to inspect available groups, resources, and object payloads.

## Assets

- `scripts/explore-k8s-api.sh`
- `yamls/api-discovery-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
./scripts/explore-k8s-api.sh
kubectl get --raw /api | head -c 300 && echo
kubectl get --raw /apis | head -c 300 && echo
```

## Expected output

- API discovery endpoints return version/group payloads.
- Script output shows accessible resources and confirms cluster API reachability.

## Video close - fast validation

```bash
kubectl cluster-info
kubectl api-resources | head -n 25
kubectl api-versions | head -n 20
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common API auth, discovery, and endpoint query failures.
