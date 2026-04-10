# 2.5.5 EndpointSlices

- Summary: EndpointSlices is a core Kubernetes concept that needs to be understood both declaratively and operationally.
- Content: This section explains endpointslices in practical Kubernetes terms and ties it back to observable cluster behavior.
- Lab: Review the assets here, apply the sample manifest if provided, and inspect the resulting state with kubectl.

## Assets

- `yamls/2-5-5-endpointslices-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/2-5-5-endpointslices-notes.yaml
kubectl get cm -n kube-system 2-5-5-endpointslices-notes -o name
kubectl get endpointslices -A 2>/dev/null | head -n 20
```

## Expected output

- ConfigMap `2-5-5-endpointslices-notes` in `kube-system`; EndpointSlices list for Services with ready pods.

## Video close - fast validation

```bash
kubectl get endpointslices -A 2>/dev/null | head -n 25
kubectl get svc -A | head -n 15
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common Endpoints vs EndpointSlice confusion, stale endpoints, and dual-stack addressType mismatches.
