# 2.5.2 Ingress

- Summary: Ingress is a core Kubernetes concept that needs to be understood both declaratively and operationally.
- Content: This section explains ingress in practical Kubernetes terms and ties it back to observable cluster behavior.
- Lab: Review the assets here, apply the sample manifest if provided, and inspect the resulting state with kubectl.

## Assets

- `scripts/inspect-2-5-2-ingress.sh`
- `yamls/2-5-2-ingress-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/2-5-2-ingress-notes.yaml
bash scripts/inspect-2-5-2-ingress.sh
```

## Expected output

- ConfigMap `2-5-2-ingress-notes` in `kube-system`; `kubectl get ingress -A` runs (may be empty on a fresh cluster).

## Video close - fast validation

```bash
bash scripts/inspect-2-5-2-ingress.sh
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common Ingress class, backend Service reference, and TLS secret mismatches.
