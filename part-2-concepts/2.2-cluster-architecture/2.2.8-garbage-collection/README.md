# 2.2.8 Garbage Collection — teaching transcript

## Intro

**ownerReferences** drive cascading deletion; bad ownership → orphans.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

**Teaching tip:** `garbage-collection-demo.sh` **applies** YAML into **`gc-demo`** — skip redundant apply in lab.

## Lab — Quick Start

**What happens when you run this:**  
- Script applies demo; lists deploy, RS, pods in `gc-demo`.  
- Use `kubectl get ... -o yaml` locally to inspect ownerRefs.

```bash
chmod +x scripts/*.sh
./scripts/garbage-collection-demo.sh
kubectl get deploy,rs,pods -n gc-demo -l app=gc-demo
```

**Expected:**  
Ownership chain visible; deleting parent removes dependents when refs correct.

## Video close — fast validation

**What happens when you run this:**  
Labeled resources; events; api-resources grep for types.

```bash
kubectl get all -n gc-demo -l app=gc-demo
kubectl get events -n gc-demo --sort-by=.lastTimestamp | tail -n 20
kubectl api-resources | grep -E '^replicasets|^deployments|^pods' || true
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/garbage-collection-demo.sh` | Apply + get |
| `yamls/garbage-collection-demo.yaml` | Demo |
| `yamls/failure-troubleshooting.yaml` | ownerRef / orphans |

## Cleanup

```bash
kubectl delete namespace gc-demo --ignore-not-found
```

## Next

[2.2.9 Mixed version proxy](../2.2.9-mixed-version-proxy/README.md)
