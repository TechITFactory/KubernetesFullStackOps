# 2.4.1.6 Pod Hostname

- Summary: Pods get DNS and hostname behavior from pod metadata, service settings, and explicit hostname fields.
- Content: Explain hostname, subdomain, and DNS identity patterns.
- Lab: Apply the pod hostname example and inspect `/etc/hosts` and DNS behavior.

## Assets

- `yamls/pod-hostname-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/pod-hostname-demo.yaml
kubectl wait --for=condition=Ready pod/pod-hostname-demo --timeout=120s
kubectl exec pod/pod-hostname-demo -- hostname
```

## Expected output

- Pod reports hostname/DNS settings consistent with `hostname` / `subdomain` fields in the manifest.

## Video close - fast validation

```bash
kubectl get pod pod-hostname-demo -o wide
kubectl exec pod/pod-hostname-demo -- cat /etc/hosts | head
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common DNS/hostname and cluster networking failures.
