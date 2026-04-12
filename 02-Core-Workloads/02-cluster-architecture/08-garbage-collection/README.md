# Garbage Collection — teaching transcript

## Intro

Kubernetes garbage collection (GC) is how orphaned objects and unused resources are cleaned up automatically. It has two distinct mechanisms.

**ownerReference GC** — every object created by a controller has `metadata.ownerReferences` set, pointing back to its owner. When an owner is deleted, the GC controller finds all objects referencing that owner's UID and deletes them too. This is what makes `kubectl delete deployment` also delete the ReplicaSet and Pods. Bad or missing ownerReferences cause orphans — objects that outlive their owner and consume resources silently.

**Image GC** — the kubelet on each node runs a separate GC process that removes unused container images when disk usage exceeds a configurable threshold (default: evict images when disk hits 85%, target 80%). This prevents nodes from filling up with stale images from old deployments.

**Prerequisites:** [Part 1](../../../01-Local-First-Operations/README.md).

---

## Flow of this lesson

```
  [ Step 1 ]              [ Step 2 ]                [ Step 3 ]
  Run script       →      Inspect ownerReferences  →  Clean up
  (apply demo             on RS and Pods
  Deployment)             (jsonpath)
```

**Say:** "Three steps. Apply the demo Deployment to create a full ownership chain — Deployment owns ReplicaSet owns Pods. Then we read the ownerReferences directly from the objects to see how GC tracks ownership. Then clean up and watch the cascade."

---

## Step 1 — Apply the demo

**What happens when you run this:**
`garbage-collection-demo.sh` creates namespace `gc-demo` and a Deployment inside it. Once the Deployment controller and ReplicaSet controller have run, there is a complete ownership chain: Deployment → ReplicaSet → Pods.

**Say:** "The script applies one manifest — a Deployment. By the time we inspect, we have a Deployment, a ReplicaSet, and at least one Pod. Each has ownerReferences pointing up the chain. This is what lets the garbage collector know who to delete when the owner goes away."

**Run:**

```bash
chmod +x scripts/*.sh
./scripts/garbage-collection-demo.sh
kubectl get deploy,rs,pods -n gc-demo -l app=gc-demo
```

**Expected:**
Deployment, one ReplicaSet, and one or more Pods all listed. All in healthy state.

---

## Step 2 — Inspect ownerReferences

**What happens when you run this:**
The jsonpath expressions extract `ownerReferences` from the ReplicaSet and from the first Pod. Each ownerReference contains `kind`, `name`, and `uid` — the UID is what the GC controller actually uses, not the name.

**Say:** "Notice the UID in the Pod's ownerReference matches the UID of the ReplicaSet. And the UID in the ReplicaSet's ownerReference matches the Deployment's UID. That UID chain is what garbage collection follows. If you delete the Deployment, the GC controller finds all objects with ownerReferences pointing to that Deployment UID and deletes them."

**Run:**

```bash
kubectl get rs -n gc-demo -o jsonpath='{range .items[*]}{.metadata.name}{" owned by "}{.metadata.ownerReferences[0].kind}{"/"}{.metadata.ownerReferences[0].name}{"\n"}{end}'
kubectl get pods -n gc-demo -o jsonpath='{range .items[*]}{.metadata.name}{" owned by "}{.metadata.ownerReferences[0].kind}{"/"}{.metadata.ownerReferences[0].name}{"\n"}{end}'
```

**Expected:**
ReplicaSet shows `owned by Deployment/<name>`. Each Pod shows `owned by ReplicaSet/<name>`.

---

## Step 3 — Clean up and observe cascade

**What happens when you run this:**
Deleting the namespace removes everything inside it in cascade order. `--ignore-not-found` prevents errors on re-runs.

**Say:** "I delete the namespace. The GC controller finds the Deployment, then finds the ReplicaSet owned by that Deployment, then finds the Pods owned by that ReplicaSet. Everything is deleted in dependency order. This is the same mechanism that runs when you delete any owner object — it's not special to namespace deletion."

**Run:**

```bash
kubectl delete namespace gc-demo --ignore-not-found
```

**Expected:**
`namespace "gc-demo" deleted`. No resources remain.

---

## Troubleshooting

- **`Pods still running after Deployment deleted`** → check if you used `--cascade=orphan`; the Pods' ownerReferences point to a deleted RS UID; the GC controller ignores them; delete manually with `kubectl delete pods -n <namespace> --all`.
- **`Namespace stuck in Terminating`** → a resource inside has a finalizer that is not being cleared; check `kubectl get all -n <namespace>` for stuck resources; identify the finalizer with `kubectl get <resource> -o yaml | grep finalizer`; fix or force-remove it.
- **`ReplicaSet not deleted after Deployment delete`** → GC is asynchronous; wait 10–30 seconds; if still present, check GC controller logs: `kubectl logs -n kube-system -l component=kube-controller-manager | grep garbage`.
- **`DiskPressure from stale images`** → the image GC on the node should handle this; if it is not running, check kubelet logs; manually clean with `crictl rmi --prune` (containerd) or `docker image prune` (docker); do not remove images that running containers depend on.
- **`ownerReferences pointing to nonexistent UID`** → an orphaned object; the GC controller will not delete it because the owner is already gone and no cascade is triggered; delete manually.

---

## Learning objective

- Explain ownerReference-based garbage collection: how the GC controller finds and deletes dependents.
- Read ownerReferences from a ReplicaSet and Pod using jsonpath.
- Describe the two types of garbage collection in Kubernetes (ownerReference GC and image GC).

## Why this matters

Orphaned resources — ReplicaSets from deleted Deployments, Pods from deleted Jobs, stale ConfigMaps — accumulate silently and consume etcd storage and node disk. Understanding ownerReferences lets you diagnose why objects are still present after a delete, and understanding image GC explains why nodes hit `DiskPressure` after many deployments.

---

## Video close — fast validation

**What happens when you run this:**
All labeled resources in the namespace; recent namespace events; API resource types for context. All read-only.

**Say:** "api-resources grep shows which resource types have GC semantics — anything that can be an owner or a dependent. Events show the GC cascade in action after a delete."

```bash
kubectl get all -n gc-demo -l app=gc-demo
kubectl get events -n gc-demo --sort-by=.lastTimestamp | tail -n 20
kubectl api-resources | grep -E '^replicasets|^deployments|^pods' || true
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/garbage-collection-demo.sh` | Apply demo Deployment and list resources |
| `yamls/garbage-collection-demo.yaml` | Demo Deployment in gc-demo namespace |
| `yamls/failure-troubleshooting.yaml` | ownerReference and orphan hints |

---

## Cleanup

```bash
kubectl delete namespace gc-demo --ignore-not-found
```

---

## Next

[2.2.9 Mixed version proxy](../09-mixed-version-proxy/README.md)
