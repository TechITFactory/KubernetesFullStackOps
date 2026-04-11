# 2.3.3 Runtime Class — teaching transcript

## Intro

**RuntimeClass** maps a pod’s `runtimeClassName` to a **handler** the node’s runtime must support (sandboxed runtimes, different OCI stacks, etc.).

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

**Teaching tip:** This lesson creates a **cluster-scoped** `RuntimeClass` object. **Scheduling a Pod** with `runtimeClassName: sandboxed-runtime` only works if nodes advertise that handler — many labs have no such runtime; treat apply here as **API learning**, not guaranteed pod success.

## Lab — Quick Start

**What happens when you run this:**  
- Apply `RuntimeClass` `sandboxed-runtime` with handler `sandboxed`.  
- List and describe that object — no workload required.

```bash
kubectl apply -f yamls/runtimeclass-demo.yaml
kubectl get runtimeclass
kubectl describe runtimeclass sandboxed-runtime
```

**Expected:**  
`sandboxed-runtime` exists; handler `sandboxed` in spec.

## Video close — fast validation

**What happens when you run this:**  
RuntimeClass wide; nodes wide (compare to whether your platform actually supports the handler).

```bash
kubectl get runtimeclass -o wide
kubectl get nodes -o wide
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/runtimeclass-demo.yaml` | RuntimeClass manifest |
| `yamls/failure-troubleshooting.yaml` | Handler mismatch / scheduling |

## Cleanup

```bash
kubectl delete runtimeclass sandboxed-runtime --ignore-not-found
```

## Next

[2.3.4 Container lifecycle hooks](../2.3.4-container-lifecycle-hooks/README.md)
