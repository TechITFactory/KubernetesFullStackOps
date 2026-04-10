# 2.5.9 Topology Aware Routing

- Summary: Topology Aware Routing is a core Kubernetes concept that needs to be understood both declaratively and operationally.
- Content: This section explains topology aware routing in practical Kubernetes terms and ties it back to observable cluster behavior.
- Lab: Review the assets here, apply the sample manifest if provided, and inspect the resulting state with kubectl.

## Assets

- `yamls/2-5-9-topology-aware-routing-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/2-5-9-topology-aware-routing-notes.yaml
kubectl get cm -n kube-system 2-5-9-topology-aware-routing-notes -o name
kubectl explain service.spec.trafficDistribution 2>/dev/null | head -n 15 || kubectl explain service.spec 2>/dev/null | head -n 20
```

## Expected output

- ConfigMap `2-5-9-topology-aware-routing-notes` in `kube-system`; `kubectl explain` shows fields available on your server version (names shifted across releases).

## Video close - fast validation

```bash
kubectl get svc -A -o wide 2>/dev/null | head -n 20
kubectl get endpointslices -A 2>/dev/null | head -n 15
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common zone/region label mismatches, hints ignored by kube-proxy, and expectations vs actual topology signals.
