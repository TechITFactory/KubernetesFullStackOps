# 2.3.1 Images

- Summary: Container images are immutable workload inputs and should be taught with pull policy, tags versus digests, and registry trust in mind.
- Content: Cover image references, caching, pull policies, and why digest pinning matters in serious environments.
- Lab: Apply the image demo and inspect the pulled image details from a running pod.

## Assets

- `yamls/image-pull-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/image-pull-demo.yaml
kubectl wait --for=condition=Ready pod/image-pull-demo --timeout=120s
kubectl get pod image-pull-demo -o jsonpath='{.spec.containers[0].image}{"\n"}{.spec.containers[0].imagePullPolicy}{"\n"}'
```

## Expected output

- Pod reaches `Ready` with `nginx:1.27` and `imagePullPolicy: IfNotPresent`.
- Image reference and pull policy match the manifest.

## Video close - fast validation

```bash
kubectl get pod image-pull-demo -o wide
kubectl describe pod image-pull-demo | sed -n '/Events:/,$p'
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common image pull, registry auth, and `ImagePullBackOff` failures.
