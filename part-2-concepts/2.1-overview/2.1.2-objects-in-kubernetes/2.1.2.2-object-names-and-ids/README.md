# 2.1.2.2 Object Names and IDs — teaching transcript

## Intro

`metadata.name` vs `generateName` vs immutable **`metadata.uid`**.

**Prerequisites:** [Part 1](../../../../part-1-getting-started/README.md).

**Teaching tip:** `create` may run twice in Video close — second run can fail if object exists; use delete between takes.

## Lab — Quick Start

**What happens when you run this:**  
- `kubectl create -f` — creates ConfigMap(s) using `generateName` (name gets random suffix).  
- `kubectl get ... custom-columns` — prints **name** and **uid** side by side.

```bash
kubectl create -f yamls/object-name-and-uid-demo.yaml
kubectl get cm -n default -l training.k8sops.io/lesson=object-names-and-ids -o custom-columns=NAME:.metadata.name,UID:.metadata.uid
```

**Expected:**  
Name prefix `generated-object-...`; UID non-empty.

## Video close — fast validation

**What happens when you run this:**  
Recreate (fails if already exists — delete first), show YAML head, **delete by label** (cleanup).

```bash
kubectl delete cm -n default -l training.k8sops.io/lesson=object-names-and-ids --ignore-not-found
kubectl create -f yamls/object-name-and-uid-demo.yaml
kubectl get cm -n default -l training.k8sops.io/lesson=object-names-and-ids -o yaml | head -n 40
kubectl delete cm -n default -l training.k8sops.io/lesson=object-names-and-ids
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/object-name-and-uid-demo.yaml` | generateName demo |
| `yamls/failure-troubleshooting.yaml` | Name / UID issues |

## Next

[2.1.2.3 Labels and selectors](../2.1.2.3-labels-and-selectors/README.md)
