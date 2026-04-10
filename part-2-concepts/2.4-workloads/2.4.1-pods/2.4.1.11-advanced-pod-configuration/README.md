# 2.4.1.11 Advanced Pod Configuration

- Summary: Advanced pod configuration combines scheduling, security, storage, networking, and lifecycle settings in one place.
- Content: Use this section to show that complex pods are usually where multiple Kubernetes concepts intersect.
- Lab: Review the advanced pod example and identify the purpose of each major section.

## Assets

- `yamls/advanced-pod-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/advanced-pod-demo.yaml
kubectl wait --for=condition=Ready pod/advanced-pod-demo --timeout=120s
kubectl get pod advanced-pod-demo -o yaml | sed -n '1,50p'
```

## Expected output

- Advanced pod fields from the manifest are visible in live object YAML.

## Video close - fast validation

```bash
kubectl describe pod advanced-pod-demo | sed -n '/Security Context:/,/QoS Class:/p'
kubectl get pod advanced-pod-demo -o wide
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common security context, sysctl, and scheduling constraint failures.
