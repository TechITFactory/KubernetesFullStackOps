# 2.1.2.7 Finalizers — teaching transcript

## Intro

Finalizers block **deletion** until controllers finish cleanup — or forever if broken.

**Prerequisites:** [Part 1](../../../../part-1-getting-started/README.md).

**Teaching tip:** The `patch` clearing finalizers is a **teaching** escape hatch; in production, fix the controller first.

## Lab — Quick Start

**What happens when you run this:**  
- Apply ConfigMap with finalizer.  
- Show finalizers.  
- `delete --wait=false` → object stuck with `deletionTimestamp`.  
- `patch` removes finalizers → object disappears.

```bash
kubectl apply -f yamls/finalizer-demo.yaml
kubectl get cm finalizer-demo -n default -o jsonpath='{.metadata.finalizers}{"\n"}'
kubectl delete configmap finalizer-demo -n default --wait=false
kubectl get cm finalizer-demo -n default -o jsonpath='{.metadata.deletionTimestamp}{"\n"}' 2>/dev/null || true
kubectl patch configmap finalizer-demo -n default -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl get cm finalizer-demo -n default 2>/dev/null || echo "ConfigMap removed"
```

**Expected:**  
Stuck Terminating then removed after patch.

## Video close — fast validation

**What happens when you run this:**  
One-liner cleanup path: apply, show finalizers line, delete+patch if needed.

```bash
kubectl apply -f yamls/finalizer-demo.yaml
kubectl get cm finalizer-demo -n default -o yaml | grep -E 'finalizers:|deletionTimestamp:' || true
kubectl delete cm finalizer-demo -n default --wait=false 2>/dev/null; kubectl patch cm finalizer-demo -n default -p '{"metadata":{"finalizers":[]}}' --type=merge 2>/dev/null || true
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/finalizer-demo.yaml` | Finalizer demo |
| `yamls/failure-troubleshooting.yaml` | Stuck Terminating |

## Next

[2.1.2.8 Owners and dependents](../2.1.2.8-owners-and-dependents/README.md)
