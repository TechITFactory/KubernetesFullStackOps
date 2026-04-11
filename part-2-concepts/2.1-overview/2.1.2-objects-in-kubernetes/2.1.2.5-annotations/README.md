# 2.1.2.5 Annotations — teaching transcript

## Intro

Annotations: **non-identifying** metadata (tooling, git SHAs, hints). Not for selectors.

**Prerequisites:** [Part 1](../../../../part-1-getting-started/README.md).

## Lab — Quick Start

**What happens when you run this:**  
- Apply ConfigMap with annotations.  
- `jsonpath` prints `metadata.annotations` (truncated in terminal).

```bash
kubectl apply -f yamls/annotations-demo.yaml
kubectl get cm annotations-demo -n default -o jsonpath='{.metadata.annotations}' | head -c 200; echo
```

**Expected:**  
Custom keys under `metadata.annotations`.

## Video close — fast validation

**What happens when you run this:**  
`describe` annotation section; **delete** ConfigMap.

```bash
kubectl describe cm annotations-demo -n default | sed -n '/Annotations:/,/Data/p'
kubectl delete cm annotations-demo -n default --ignore-not-found
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/annotations-demo.yaml` | Annotated object |
| `yamls/failure-troubleshooting.yaml` | Size limits / confusion with labels |

## Next

[2.1.2.6 Field selectors](../2.1.2.6-field-selectors/README.md)
