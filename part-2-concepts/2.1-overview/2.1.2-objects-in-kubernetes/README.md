# 2.1.2 Objects In Kubernetes — teaching transcript

## Intro

Kubernetes **objects** are declarative records: metadata, spec, status, ownership, and lifecycle hooks (finalizers). This module breaks that down into teachable slices.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

**Teaching tip:** Run subsection lessons **in order** when possible; each has **What happens** before commands.

## Object lifecycle (mental model)

**Say:**
Every Kubernetes object follows this path. You write a manifest, apply it, the API server validates and stores it in etcd. Controllers watch etcd for changes and reconcile actual state. Node agents — kubelet — receive that desired state and make it real on the node.

```
  Manifest YAML
       │
       ▼ kubectl apply
  API server (validates + stores)
       │                    ▲
       ▼                    │ reconcile
     etcd            Controllers
  (desired state)
       │
       ▼
  Node agents (kubelet)
```

## Children (work in order)

- [2.1.2.1 Kubernetes object management](2.1.2.1-kubernetes-object-management/README.md)
- [2.1.2.2 Object names and IDs](2.1.2.2-object-names-and-ids/README.md)
- [2.1.2.3 Labels and selectors](2.1.2.3-labels-and-selectors/README.md)
- [2.1.2.4 Namespaces](2.1.2.4-namespaces/README.md)
- [2.1.2.5 Annotations](2.1.2.5-annotations/README.md)
- [2.1.2.6 Field selectors](2.1.2.6-field-selectors/README.md)
- [2.1.2.7 Finalizers](2.1.2.7-finalizers/README.md)
- [2.1.2.8 Owners and dependents](2.1.2.8-owners-and-dependents/README.md)
- [2.1.2.9 Recommended labels](2.1.2.9-recommended-labels/README.md)
- [2.1.2.10 Storage versions](2.1.2.10-storage-versions/README.md)

## Cross-module lab (labels demo)

**What happens when you run this:**  
Applies the **2.1.2.3** demo manifest from this directory’s path, lists pod labels cluster-wide for that demo, then deletes the demo (cleanup).

```bash
kubectl apply -f 2.1.2.3-labels-and-selectors/yamls/labels-and-selectors-demo.yaml
kubectl get pods --show-labels -A | head -n 30
kubectl delete -f 2.1.2.3-labels-and-selectors/yamls/labels-and-selectors-demo.yaml --ignore-not-found
```

**Expected:**  
Objects create cleanly; label columns visible; delete succeeds.

## Module wrap — quick validation

**What happens when you run this:**  
API resource grep, namespaces, short cross-namespace list — read-only.

```bash
kubectl api-resources | grep -E "^configmaps|^pods|^deployments" || true
kubectl get ns
kubectl get all -A | head -n 20
```

## Failure troubleshooting

Each `2.1.2.*` lesson includes `yamls/failure-troubleshooting.yaml` for apply conflicts, selectors, namespaces, finalizers, ownership, and version drift.

## Next

[2.1.3 The Kubernetes API](../2.1.3-the-kubernetes-api/README.md)
