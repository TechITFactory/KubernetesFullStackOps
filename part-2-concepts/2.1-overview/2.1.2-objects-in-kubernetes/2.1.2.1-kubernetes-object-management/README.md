# 2.1.2.1 Kubernetes Object Management — teaching transcript

## Intro

**Declarative** `apply` vs one-off **create**: reconcile desired state safely and repeatably.

**Prerequisites:** [Part 1](../../../../part-1-getting-started/README.md).

**Teaching tip:** `scripts/object-management-demo.sh` header describes exact API calls.

## Lab — Quick Start

**What happens when you run this:**  
- Script **applies** `object-management-demo.yaml` (namespace `object-management-demo` + Deployment).  
- Second line shows deploy + pods in that namespace.

```bash
chmod +x scripts/*.sh
./scripts/object-management-demo.sh
kubectl get deploy,pods -n object-management-demo -o wide
```

**Expected:**  
Namespace exists; Deployment available; Pods `Running`.

## Video close — fast validation

**What happens when you run this:**  
Recap then **delete** manifest (removes namespace and contents).

```bash
kubectl get deploy,pods -n object-management-demo
kubectl delete -f yamls/object-management-demo.yaml --ignore-not-found
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/object-management-demo.sh` | Apply + get |
| `yamls/object-management-demo.yaml` | Demo namespace + Deployment |
| `yamls/failure-troubleshooting.yaml` | Apply / immutable field issues |

## Next

[2.1.2.2 Object names and IDs](../2.1.2.2-object-names-and-ids/README.md)
