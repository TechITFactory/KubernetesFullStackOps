# 2.5.8 IPv4/IPv6 Dual-Stack

- Summary: IPv4/IPv6 Dual-Stack is a core Kubernetes concept that needs to be understood both declaratively and operationally.
- Content: This section explains ipv4/ipv6 dual-stack in practical Kubernetes terms and ties it back to observable cluster behavior.
- Lab: Review the assets here, apply the sample manifest if provided, and inspect the resulting state with kubectl.

## Assets

- `yamls/2-5-8-ipv4-ipv6-dual-stack-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/2-5-8-ipv4-ipv6-dual-stack-notes.yaml
kubectl get cm -n kube-system 2-5-8-ipv4-ipv6-dual-stack-notes -o name
kubectl get svc kubernetes -o jsonpath='{.spec.clusterIPs}' 2>/dev/null; echo
```

## Expected output

- ConfigMap `2-5-8-ipv4-ipv6-dual-stack-notes` in `kube-system`; cluster shows dual-stack behavior only when the control plane and CNI are configured for it.

## Video close - fast validation

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name} {.status.addresses[*].type}{"\n"}{end}' | head -n 10
kubectl get svc -A -o custom-columns=NAME:.metadata.name,IPS:.spec.clusterIPs --no-headers 2>/dev/null | head -n 15
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common ipFamilyPolicy/ipFamilies mistakes, CNI dual-stack gaps, and Service address family skew.
