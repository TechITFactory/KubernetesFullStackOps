# 2.5.4 Gateway API

- Summary: Gateway API is a core Kubernetes concept that needs to be understood both declaratively and operationally.
- Content: This section explains gateway api in practical Kubernetes terms and ties it back to observable cluster behavior.
- Lab: Review the assets here, apply the sample manifest if provided, and inspect the resulting state with kubectl.

## Assets

- `yamls/2-5-4-gateway-api-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/2-5-4-gateway-api-notes.yaml
kubectl get cm -n kube-system 2-5-4-gateway-api-notes -o name
kubectl api-resources 2>/dev/null | grep -i gateway || true
```

## Expected output

- ConfigMap `2-5-4-gateway-api-notes` in `kube-system`; Gateway API CRDs appear when the implementation is installed (often empty on minimal clusters).

## Video close - fast validation

```bash
kubectl api-resources 2>/dev/null | grep -iE 'gateway|grpcroute|httproute' || true
kubectl get gateway -A 2>/dev/null || true
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common CRD/controller install gaps, listener conflicts, and backendRef resolution failures.
