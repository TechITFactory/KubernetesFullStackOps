# 2.1.2.9 Recommended Labels — teaching transcript

## Intro

Use **`app.kubernetes.io/*`** consistently so tools and humans agree on app identity.

**Prerequisites:** [Part 1](../../../../part-1-getting-started/README.md).

## Lab — Quick Start

**What happens when you run this:**  
- Apply Deployment with recommended labels.  
- Wait available.  
- Show labels; query by `part-of`.

```bash
kubectl apply -f yamls/recommended-labels-demo.yaml
kubectl wait --for=condition=available deployment/labels-demo --timeout=120s
kubectl get deploy labels-demo -n default --show-labels
kubectl get deploy -n default -l 'app.kubernetes.io/part-of=overview-module'
```

**Expected:**  
`labels-demo` shows standard labels; selector query returns it.

## Video close — fast validation

**What happens when you run this:**  
jsonpath label dump; **delete** demo.

```bash
kubectl get deploy labels-demo -n default -o jsonpath='{range $k,$v := .metadata.labels}{$k}={$v}{"\n"}{end}' | grep app.kubernetes.io
kubectl delete -f yamls/recommended-labels-demo.yaml --ignore-not-found
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/recommended-labels-demo.yaml` | Labeled Deployment |
| `yamls/failure-troubleshooting.yaml` | Label drift |

## Next

[2.1.2.10 Storage versions](../2.1.2.10-storage-versions/README.md)
