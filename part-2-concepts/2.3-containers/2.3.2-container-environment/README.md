# 2.3.2 Container Environment — teaching transcript

## Intro

Inside the container, the process sees **image defaults**, **command/args**, **`env`**, **downward API** (`fieldRef`), DNS, and mounts — all driven from the Pod spec.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md); cluster can pull `busybox:1.36`.

**Teaching tip:** Manifest has no `namespace:` → Pod is created in your **current** context’s default namespace (usually `default`).

## Lab — Quick Start

**What happens when you run this:**  
- Apply Pod `container-environment-demo` (`env-demo` container runs `env && sleep 3600`).  
- Wait until Ready.  
- `exec printenv` shows `TRAINING_MODULE`, `POD_NAME` (from fieldRef), plus Kubernetes-injected vars.

```bash
kubectl apply -f yamls/container-environment-demo.yaml
kubectl wait --for=condition=Ready pod/container-environment-demo --timeout=120s
kubectl exec pod/container-environment-demo -c env-demo -- printenv | head -n 30
```

**Expected:**  
`TRAINING_MODULE=2.3.2`, `POD_NAME=container-environment-demo`, plus standard K8s env where injected.

## Video close — fast validation

**What happens when you run this:**  
Wide pod; describe excerpt between Environment and Mounts — read-only.

```bash
kubectl get pod container-environment-demo -o wide
kubectl describe pod container-environment-demo | sed -n '/Environment:/,/Mounts:/p'
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/container-environment-demo.yaml` | env + fieldRef demo |
| `yamls/failure-troubleshooting.yaml` | env / downward API issues |

## Cleanup

```bash
kubectl delete pod container-environment-demo --ignore-not-found
```

## Next

[2.3.3 Runtime class](../2.3.3-runtime-class/README.md)
