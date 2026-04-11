# 2.3.1 Images — teaching transcript

## Intro

Images are **immutable inputs**: reference by tag or **digest**, control pulls with **imagePullPolicy**, and expect registry auth to surface as `ImagePullBackOff` when wrong.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md); cluster that can pull `nginx:1.27`.

**Teaching tip:** Demo Pod lives in **`default`** as `image-pull-demo`.

## Lab — Quick Start

**What happens when you run this:**  
- `apply` creates Pod `image-pull-demo` with `nginx:1.27` and `IfNotPresent`.  
- `kubectl wait` blocks until **Ready** (or timeout).  
- `jsonpath` prints image + pull policy from the live spec.

```bash
kubectl apply -f yamls/image-pull-demo.yaml
kubectl wait --for=condition=Ready pod/image-pull-demo -n default --timeout=120s
kubectl get pod image-pull-demo -n default -o jsonpath='{.spec.containers[0].image}{"\n"}{.spec.containers[0].imagePullPolicy}{"\n"}'
```

**Expected:**  
Pod `Ready`; lines show `nginx:1.27` and `IfNotPresent`.

## Video close — fast validation

**What happens when you run this:**  
Wide status; **Events** tail (pull, schedule, start) — read-only.

```bash
kubectl get pod image-pull-demo -n default -o wide
kubectl describe pod image-pull-demo -n default | sed -n '/Events:/,$p'
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/image-pull-demo.yaml` | Pod + pull policy |
| `yamls/failure-troubleshooting.yaml` | ImagePullBackOff / auth |

## Cleanup

```bash
kubectl delete pod image-pull-demo -n default --ignore-not-found
```

## Next

[2.3.2 Container environment](../2.3.2-container-environment/README.md)
