# 2.3.2 Container Environment

- Summary: A container's environment is assembled from image defaults, command overrides, env vars, and injected Kubernetes metadata.
- Content: Show how args, env, downward API, DNS, and mounted data shape the process environment inside the container.
- Lab: Run the environment demo and inspect variables and mounted metadata.

## Assets

- `yamls/container-environment-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/container-environment-demo.yaml
kubectl wait --for=condition=Ready pod/container-environment-demo --timeout=120s
kubectl exec pod/container-environment-demo -c env-demo -- printenv | head -n 30
```

## Expected output

- Pod is `Running` and env vars from the manifest (and downward API where used) appear in `printenv`.

## Video close - fast validation

```bash
kubectl get pod container-environment-demo -o wide
kubectl describe pod container-environment-demo | sed -n '/Environment:/,/Mounts:/p'
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common env, command, volume mount, and downward API failures.
