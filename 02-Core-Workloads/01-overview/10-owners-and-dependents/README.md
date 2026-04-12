# Owners and Dependents — teaching transcript

## Intro

When you delete a Deployment, its ReplicaSet and Pods disappear automatically. That's not magic — it's `ownerReferences`.

Every object created by a controller has `metadata.ownerReferences` set — a list pointing back to the object that owns it. Deployment → ReplicaSet → Pod is the standard chain. If you delete the Deployment, the garbage collector sees that the ReplicaSet's owner is gone and deletes the ReplicaSet. That triggers the Pod deletions too.

This matters in two scenarios. First, understanding why cascade deletes work the way they do. Second, debugging orphan objects — objects left behind when their owner was deleted without proper garbage collection. An orphan ReplicaSet with its owner gone will keep its pods running indefinitely, consuming resources you think you've removed.

**Prerequisites:** [Part 1](../../01-Local-First-Operations/README.md).

**Teaching tip:** `scripts/show-owner-references.sh` expects namespace **`owner-demo`** to exist and have objects in it — apply the manifest before running the script.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/02-Core-Workloads/01-overview/10-owners-and-dependents"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  [ Step 1 ]          [ Step 2 ]          [ Step 3 ]
  Apply demo   →      Wait for    →       Inspect owner
  Deployment          rollout             chain
```

**Say:**

Three steps. Apply the demo Deployment, wait for rollout, then inspect the ownerReferences chain with both the script and manual kubectl.

---

## Step 1 — Apply the demo

**What happens when you run this:**
`kubectl apply -f yamls/owner-reference-demo.yaml` creates namespace `owner-demo` and a Deployment inside it. The Deployment controller creates a ReplicaSet; the ReplicaSet controller creates Pods. All with `ownerReferences` set. Declarative; safe to re-run.

**Say:**
I'm applying one manifest — one Deployment. But that triggers a cascade of creations. By the time this finishes, there's a namespace, a Deployment, a ReplicaSet, and one or more Pods — each one owning the next in the chain.

**Run:**

```bash
cd "$COURSE_DIR/02-Core-Workloads/01-overview/10-owners-and-dependents"
kubectl apply -f yamls/owner-reference-demo.yaml
```

**Expected:**
`namespace/owner-demo created`, `deployment.apps/owner-demo created`.

---

## Step 2 — Wait for rollout

**What happens when you run this:**
`kubectl wait --for=condition=available deployment/owner-demo -n owner-demo --timeout=120s` blocks until the Deployment's `Available` condition is true — all desired pods are running and passing readiness. Read-only.

**Say:**
I wait before inspecting so the full chain is in place. If I look at ownerReferences while pods are still starting, I might see the ReplicaSet before pods exist.

**Run:**

```bash
kubectl wait --for=condition=available deployment/owner-demo -n owner-demo --timeout=120s
chmod +x scripts/*.sh
```

**Expected:**
`deployment.apps/owner-demo condition met`.

---

## Step 3 — Inspect the owner chain

**What happens when you run this:**
`show-owner-references.sh` reads `ownerReferences` on both the ReplicaSet and the Pods using jsonpath, printing the chain. All read-only.

**Say:**
What I want to see: the Pod's owner is a ReplicaSet. The ReplicaSet's owner is the Deployment. Each reference includes the `kind`, `name`, and `uid` of the owner. The UID is the important part — that's how garbage collection identifies the exact object, not just the name.

**Run:**

```bash
./scripts/show-owner-references.sh
```

**Expected:**
Output showing ReplicaSet → Deployment and Pod → ReplicaSet ownership chains.

---

## How garbage collection uses ownerReferences

When you delete a Deployment:
1. The Deployment object gets `deletionTimestamp` set.
2. The garbage collector finds all objects with `ownerReferences` pointing at that Deployment UID.
3. It deletes those objects (the ReplicaSet).
4. That triggers another pass — the garbage collector finds Pods owned by the now-deleted ReplicaSet.
5. Pods are deleted.

**Cascade modes:**
- **Foreground** (default) — owner waits for dependents to be deleted first; `kubectl delete` blocks until everything is gone
- **Background** — owner is deleted immediately; garbage collector cleans up dependents asynchronously
- **Orphan** — owner is deleted without removing dependents; `ownerReferences` on dependents point to a nonexistent UID; garbage collector ignores them

```bash
# Explicit cascade mode
kubectl delete deployment owner-demo -n owner-demo --cascade=foreground
kubectl delete deployment owner-demo -n owner-demo --cascade=background
kubectl delete deployment owner-demo -n owner-demo --cascade=orphan
```

---

## Troubleshooting

- **Pods running after Deployment deleted** → check if you used `--cascade=orphan`; the pods' `ownerReferences` will point to a nonexistent UID; delete them manually with `kubectl delete pods -n owner-demo --all`
- **`show-owner-references.sh` returns nothing** → wait for the rollout to complete first; pods must exist before their ownerReferences can be read
- **ReplicaSet not cleaned up after Deployment delete** → garbage collection is async; wait a few seconds; if still present after 30s, check garbage collector logs (`kubectl logs -n kube-system -l component=kube-controller-manager`)
- **`kubectl delete -f` cleans up everything** → using the original manifest file with `kubectl delete -f` deletes all objects in the manifest — namespace + Deployment — and cascade handles the rest

---

## Learning objective

- Explain how `ownerReferences` drive cascade garbage collection.
- Trace the Deployment → ReplicaSet → Pod ownership chain using jsonpath.
- Describe the three cascade deletion modes and when to use each.

## Why this matters

When resources linger after deletion, when namespaces won't clean up, or when pods keep running after you've "deleted" them — orphaned ownerReferences are almost always involved. Understanding the ownership model means you can diagnose and fix these situations instead of deleting everything and hoping it comes back cleanly.

---

## Video close — fast validation

**What happens when you run this:**
Custom columns view showing owner chain for ReplicaSets and Pods, then delete the full manifest.

**Say:**
The `custom-columns` output shows KIND, NAME, and OWNER for every ReplicaSet and Pod in `owner-demo`. This is the ownership chain at a glance. Then I delete the namespace — everything inside cascades.

```bash
kubectl get rs,pods -n owner-demo \
  -o custom-columns=KIND:.kind,NAME:.metadata.name,OWNER:.metadata.ownerReferences[*].name \
  2>/dev/null | head -n 15
kubectl delete -f yamls/owner-reference-demo.yaml --ignore-not-found
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/show-owner-references.sh` | Prints owner chain using jsonpath |
| `yamls/owner-reference-demo.yaml` | Namespace + Deployment demo |
| `yamls/failure-troubleshooting.yaml` | Orphan and cascade deletion hints |

---

## Next

[2.1.2.9 Recommended labels](../11-recommended-labels/README.md)
