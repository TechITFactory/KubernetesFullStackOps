# 2.1.2.8 Owners and Dependents — teaching transcript

## Intro

**ownerReferences** drive garbage collection: Deployment → ReplicaSet → Pod.

**Prerequisites:** [Part 1](../../../../part-1-getting-started/README.md).

**Teaching tip:** `show-owner-references.sh` expects namespace **`owner-demo`**.

## Lab — Quick Start

**What happens when you run this:**  
- Apply demo (namespace + Deployment).  
- Wait for available.  
- Script prints RS/Pod → owner chain via jsonpath.

```bash
kubectl apply -f yamls/owner-reference-demo.yaml
kubectl wait --for=condition=available deployment/owner-demo -n owner-demo --timeout=120s
chmod +x scripts/*.sh
./scripts/show-owner-references.sh
```

**Expected:**  
Owners point up to Deployment / ReplicaSet as designed.

## Video close — fast validation

**What happens when you run this:**  
`custom-columns` owner view; **delete** full manifest (cascade).

```bash
kubectl get rs,pods -n owner-demo -o custom-columns=KIND:.kind,NAME:.metadata.name,OWNER:.metadata.ownerReferences[*].name 2>/dev/null | head -n 15
kubectl delete -f yamls/owner-reference-demo.yaml --ignore-not-found
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/show-owner-references.sh` | Owner jsonpath |
| `yamls/owner-reference-demo.yaml` | Demo deployment |
| `yamls/failure-troubleshooting.yaml` | Orphan / cascade issues |

## Next

[2.1.2.9 Recommended labels](../2.1.2.9-recommended-labels/README.md)
