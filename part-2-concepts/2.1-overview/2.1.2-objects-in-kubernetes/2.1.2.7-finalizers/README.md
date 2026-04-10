# 2.1.2.7 Finalizers

- Summary: Finalizers delay object deletion until cleanup steps complete, which is powerful but also a common source of “stuck” resources.
- Content: This subsection shows a simple finalizer example and explains why force-removing finalizers should be deliberate.
- Lab: Create the sample object, mark it for deletion, and observe finalizer behavior.

## Assets

- `yamls/finalizer-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/finalizer-demo.yaml
kubectl get cm finalizer-demo -n default -o jsonpath='{.metadata.finalizers}{"\n"}'
kubectl delete configmap finalizer-demo -n default --wait=false
kubectl get cm finalizer-demo -n default -o jsonpath='{.metadata.deletionTimestamp}{"\n"}' 2>/dev/null || true
kubectl patch configmap finalizer-demo -n default -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl get cm finalizer-demo -n default 2>/dev/null || echo "ConfigMap removed"
```

## Expected output

- After `delete`, the ConfigMap remains with `deletionTimestamp` until finalizers are cleared; patch completes deletion.

## Video close - fast validation

```bash
kubectl apply -f yamls/finalizer-demo.yaml
kubectl get cm finalizer-demo -n default -o yaml | grep -E 'finalizers:|deletionTimestamp:' || true
kubectl delete cm finalizer-demo -n default --wait=false 2>/dev/null; kubectl patch cm finalizer-demo -n default -p '{"metadata":{"finalizers":[]}}' --type=merge 2>/dev/null || true
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common stuck Terminating resources, unsafe finalizer removal, and owner-dependent deletion ordering.
