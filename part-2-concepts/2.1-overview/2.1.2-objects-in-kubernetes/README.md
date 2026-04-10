# 2.1.2 Objects In Kubernetes

- Summary: Kubernetes objects are the declarative records that define cluster intent, ownership, metadata, and lifecycle behavior.
- Content: This section drills into object management, metadata, selectors, namespaces, ownership, and storage-version concepts with concrete examples.
- Lab: Create and inspect example objects, then observe how labels, annotations, owners, and finalizers affect behavior.

## Children

- `2.1.2.1 Kubernetes Object Management`
- `2.1.2.2 Object Names and IDs`
- `2.1.2.3 Labels and Selectors`
- `2.1.2.4 Namespaces`
- `2.1.2.5 Annotations`
- `2.1.2.6 Field Selectors`
- `2.1.2.7 Finalizers`
- `2.1.2.8 Owners and Dependents`
- `2.1.2.9 Recommended Labels`
- `2.1.2.10 Storage Versions`

## Quick Start

```bash
kubectl apply -f 2.1.2.3-labels-and-selectors/yamls/labels-and-selectors-demo.yaml
kubectl get pods --show-labels
kubectl delete -f 2.1.2.3-labels-and-selectors/yamls/labels-and-selectors-demo.yaml --ignore-not-found
```

## Expected output

- Sample objects are created and can be queried with labels/selectors.
- Metadata fields (labels/annotations/owner refs/finalizers) become inspectable with `kubectl get -o yaml`.

## Module wrap - quick validation

```bash
kubectl api-resources | grep -E "^configmaps|^pods|^deployments" || true
kubectl get ns
kubectl get all -A | head -n 20
```

## Failure Troubleshooting Asset

- Each lesson `2.1.2.*` includes `yamls/failure-troubleshooting.yaml` with topic-specific symptoms (apply, selectors, namespaces, finalizers, ownership, and API version drift).
