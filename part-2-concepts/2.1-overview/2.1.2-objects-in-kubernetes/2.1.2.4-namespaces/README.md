# 2.1.2.4 Namespaces — teaching transcript

## Intro

Namespaces partition **names**, RBAC, quotas — and your default context.

**Prerequisites:** [Part 1](../../../../part-1-getting-started/README.md).

## Lab — Quick Start

**What happens when you run this:**  
- Apply namespace manifest.  
- Show labels on `overview-lab`.

```bash
kubectl apply -f yamls/namespace-demo.yaml
kubectl get ns overview-lab --show-labels
```

**Expected:**  
Namespace `overview-lab` with `purpose=training` (or labels from your YAML).

## Video close — fast validation

**What happens when you run this:**  
YAML snippet then **delete namespace** (cascades contents).

```bash
kubectl get ns overview-lab -o yaml | head -n 30
kubectl delete ns overview-lab --ignore-not-found
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/namespace-demo.yaml` | Demo namespace |
| `yamls/failure-troubleshooting.yaml` | Context / finalizer issues |

## Next

[2.1.2.5 Annotations](../2.1.2.5-annotations/README.md)
