# 2.5.1 Service

- Summary: Service is a core Kubernetes concept that needs to be understood both declaratively and operationally.
- Content: This section explains service in practical Kubernetes terms and ties it back to observable cluster behavior.
- Lab: Review the assets here, apply the sample manifest if provided, and inspect the resulting state with kubectl.

## Assets

- `scripts/inspect-2-5-1-service.sh`
- `yamls/2-5-1-service-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/2-5-1-service-notes.yaml
bash scripts/inspect-2-5-1-service.sh
```

## Expected output

- ConfigMap `2-5-1-service-notes` exists in `kube-system`; Services (and EndpointSlices when available) list without errors.

## Video close - fast validation

```bash
bash scripts/inspect-2-5-1-service.sh
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common ClusterIP/NodePort/LoadBalancer confusion, Endpoints empty, and kube-proxy datapath gaps.
