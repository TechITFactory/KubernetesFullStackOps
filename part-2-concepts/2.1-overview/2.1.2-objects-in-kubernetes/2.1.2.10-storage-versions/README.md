# 2.1.2.10 Storage Versions — teaching transcript

## Intro

**Served** API versions vs **stored** representation in etcd — matters for upgrades and deprecations.

**Prerequisites:** [Part 1](../../../../part-1-getting-started/README.md).

**Teaching tip:** Applying to **`kube-system`** needs permission; on locked-down clusters, apply to another namespace and copy notes locally instead.

## Lab — Quick Start

**What happens when you run this:**  
- Creates/updates ConfigMap **`storage-version-notes`** in `kube-system` (if RBAC allows).  
- Prints first lines of embedded `data.notes`.

```bash
kubectl apply -f yamls/storage-version-notes.yaml
kubectl get cm storage-version-notes -n kube-system -o jsonpath='{.data.notes}' | head -n 5
```

**Expected:**  
Notes text visible, or clear RBAC denial (documented in troubleshooting YAML).

## Video close — fast validation

**What happens when you run this:**  
API versions; raw `/apis/apps/v1` snippet; **delete** ConfigMap.

```bash
kubectl api-versions | head -n 20
kubectl get --raw /apis/apps/v1 2>/dev/null | head -c 120; echo
kubectl delete cm storage-version-notes -n kube-system --ignore-not-found
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/storage-version-notes.yaml` | Embedded explanation |
| `yamls/failure-troubleshooting.yaml` | Version / migration confusion |

## Next

[2.1.3 The Kubernetes API](../../2.1.3-the-kubernetes-api/README.md)
