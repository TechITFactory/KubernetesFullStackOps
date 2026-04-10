# 2.5.12 Service Internal Traffic Policy

- Summary: Service Internal Traffic Policy is a core Kubernetes concept that needs to be understood both declaratively and operationally.
- Content: This section explains service internal traffic policy in practical Kubernetes terms and ties it back to observable cluster behavior.
- Lab: Review the assets here, apply the sample manifest if provided, and inspect the resulting state with kubectl.

## Assets

- `scripts/inspect-2-5-12-service-internal-traffic-policy.sh`
- `yamls/2-5-12-service-internal-traffic-policy-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/2-5-12-service-internal-traffic-policy-notes.yaml
bash scripts/inspect-2-5-12-service-internal-traffic-policy.sh
```

## Expected output

- ConfigMap `2-5-12-service-internal-traffic-policy-notes` in `kube-system`; Services list; internal traffic policy visible on supported versions.

## Video close - fast validation

```bash
bash scripts/inspect-2-5-12-service-internal-traffic-policy.sh
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common Local vs Cluster policy surprises, kube-proxy endpoints behavior, and health check traffic loops.
