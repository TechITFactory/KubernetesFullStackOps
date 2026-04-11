# 2.1.2.3 Labels and Selectors — teaching transcript

## Intro

Labels are **queryable** metadata; selectors glue Services, Deployments, and scheduling together.

**Prerequisites:** [Part 1](../../../../part-1-getting-started/README.md).

**Teaching tip:** `scripts/query-label-selectors.sh` only **gets** — apply the YAML first.

## Lab — Quick Start

**What happens when you run this:**  
- Apply demo Deployment + Service.  
- `kubectl wait` until Deployment **available**.  
- Script lists pods/services matching course labels.

```bash
kubectl apply -f yamls/labels-and-selectors-demo.yaml
kubectl wait --for=condition=available deployment/demo-web --timeout=120s
chmod +x scripts/*.sh
./scripts/query-label-selectors.sh
```

**Expected:**  
`demo-web` deploy + svc in `default`; queries return those objects.

## Video close — fast validation

**What happens when you run this:**  
Selector-based get, then **delete** demo manifest.

```bash
kubectl get deploy,svc -n default -l app.kubernetes.io/part-of=overview-module
kubectl delete -f yamls/labels-and-selectors-demo.yaml --ignore-not-found
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/query-label-selectors.sh` | Label queries |
| `yamls/labels-and-selectors-demo.yaml` | Demo workload |
| `yamls/failure-troubleshooting.yaml` | Selector mismatch |

## Next

[2.1.2.4 Namespaces](../2.1.2.4-namespaces/README.md)
