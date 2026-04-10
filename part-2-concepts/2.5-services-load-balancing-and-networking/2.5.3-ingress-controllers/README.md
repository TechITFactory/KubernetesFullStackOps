# 2.5.3 Ingress Controllers

- Summary: Ingress Controllers is a core Kubernetes concept that needs to be understood both declaratively and operationally.
- Content: This section explains ingress controllers in practical Kubernetes terms and ties it back to observable cluster behavior.
- Lab: Review the assets here, apply the sample manifest if provided, and inspect the resulting state with kubectl.

## Assets

- `scripts/inspect-2-5-3-ingress-controllers.sh`
- `yamls/2-5-3-ingress-controllers-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/2-5-3-ingress-controllers-notes.yaml
bash scripts/inspect-2-5-3-ingress-controllers.sh
```

## Expected output

- ConfigMap `2-5-3-ingress-controllers-notes` in `kube-system`; Ingress controller pods visible if an addon/chart is installed.

## Video close - fast validation

```bash
bash scripts/inspect-2-5-3-ingress-controllers.sh
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common missing controller, webhook/cert failures, and Service external IP behavior.
