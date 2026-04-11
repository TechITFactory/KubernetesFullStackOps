# 2.1.2.7 Finalizers â€” teaching transcript

## Intro

Finalizers are the reason a Kubernetes object sometimes refuses to delete.

When you run `kubectl delete` on an object that has a finalizer, Kubernetes doesn't delete it immediately. Instead it sets `metadata.deletionTimestamp` â€” a marker that says "this object wants to be deleted" â€” and waits. The finalizer is a string in `metadata.finalizers`. A controller watches for objects with `deletionTimestamp` set and that specific finalizer, does its cleanup work, then removes the finalizer string. Once all finalizers are gone, the API server deletes the object.

The most common place you encounter finalizers as an operator: a namespace stuck in `Terminating`. Something inside it had a finalizer that a controller never cleared â€” perhaps because the controller itself was deleted, or because a CRD was removed before its objects were cleaned up.

This lesson shows you the full lifecycle: apply an object with a finalizer, delete it, watch it get stuck, and then manually clear the finalizer as an emergency escape hatch.

**Prerequisites:** [Part 1](../../part-1-getting-started/README.md).

**Teaching tip:** The `patch` that clears finalizers is a **teaching escape hatch**. In production, the right fix is restoring or fixing the controller that owns the finalizer â€” not force-clearing it, because that bypasses whatever cleanup the finalizer was protecting.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/02-Core-Workloads/01-overview/09-finalizers"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  [ Step 1 ]      [ Step 2 ]      [ Step 3 ]        [ Step 4 ]      [ Step 5 ]
  Apply demo  â†’   Read the   â†’    Delete with  â†’    Show stuck  â†’   Patch to
  object          finalizer        --wait=false      timestamp       release
```

**Say:**

Five numbered steps. Apply the demo, read its finalizer, delete with `--wait=false`, show the deletion timestamp, then patch finalizers empty. That last patch is only for labs or emergencies when the controller is gone; if a real controller still runs, I fix or redeploy that controller instead of stripping finalizers.

---

## Step 1 â€” Apply the demo object

**What happens when you run this:**
`kubectl apply -f yamls/finalizer-demo.yaml` creates a ConfigMap with a finalizer string in `metadata.finalizers`. Declarative; safe to re-run.

**Say:**
The manifest sets `metadata.finalizers: ["training.k8sops.io/demo-finalizer"]`. This is just a string â€” there's no controller watching for it in this lab cluster. That's intentional: it lets us see the stuck state without needing a real controller.

**Run:**

```bash
cd "$COURSE_DIR/02-Core-Workloads/01-overview/09-finalizers"
kubectl apply -f yamls/finalizer-demo.yaml
```

**Expected:**
`configmap/finalizer-demo created` or unchanged.

---

## Step 2 â€” Read the finalizer

**What happens when you run this:**
`kubectl get cm finalizer-demo -o jsonpath='{.metadata.finalizers}'` reads the finalizers array from the object's metadata â€” read-only.

**Say:**
The finalizers field is an array of strings. As long as any string is in that list, the object cannot be deleted. Every string must be cleared by a controller â€” or by us in an emergency.

**Run:**

```bash
kubectl get cm finalizer-demo -n default -o jsonpath='{.metadata.finalizers}{"\n"}'
```

**Expected:**
`["training.k8sops.io/demo-finalizer"]`

---

## Step 3 â€” Delete and get stuck

**What happens when you run this:**
`kubectl delete configmap finalizer-demo --wait=false` sends the delete request. The API server sets `deletionTimestamp` but cannot remove the object because the finalizer is still there. `--wait=false` returns the prompt immediately instead of blocking.

**Say:**
Normally `kubectl delete` blocks until the object is gone. With `--wait=false` I get my prompt back immediately so I can show the stuck state. In a real namespace stuck in `Terminating`, this is exactly what's happening â€” delete request received, finalizer blocking completion.

**Run:**

```bash
kubectl delete configmap finalizer-demo -n default --wait=false
```

**Expected:**
`configmap "finalizer-demo" deleted` (confusing message â€” it means the delete request was accepted, not that the object is gone).

---

## Step 4 â€” Show the stuck state

**What happens when you run this:**
`kubectl get cm finalizer-demo -o jsonpath='{.metadata.deletionTimestamp}'` reads the deletion timestamp â€” if set, the object is waiting for finalizers to clear. Read-only.

**Say:**
The object still exists. The `deletionTimestamp` is now set â€” that's the marker. Any controller watching for `training.k8sops.io/demo-finalizer` would see this, do its cleanup, and remove the finalizer. Since no such controller exists in this lab, we do it manually.

**Run:**

```bash
kubectl get cm finalizer-demo -n default -o jsonpath='{.metadata.deletionTimestamp}{"\n"}' 2>/dev/null || true
```

**Expected:**
A timestamp string â€” confirms the object is stuck in termination.

---

## Step 5 â€” Patch to release

**What happens when you run this:**
`kubectl patch configmap finalizer-demo -p '{"metadata":{"finalizers":[]}}' --type=merge` sets the finalizers array to empty. The API server sees all finalizers are gone and immediately deletes the object.

**Say:**
This patch overwrites the finalizers array with an empty list. The moment that happens, the API server's garbage collection removes the object. I only do this when the controller that should have removed the finalizer is **gone** or **broken beyond repair** and I accept skipping its cleanup. If the controller is still running, I redeploy or fix it so it clears the finalizer the right way â€” otherwise it may re-add the finalizer or leave external systems inconsistent.

**Run:**

```bash
kubectl patch configmap finalizer-demo -n default \
  -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl get cm finalizer-demo -n default 2>/dev/null || echo "ConfigMap removed"
```

**Expected:**
ConfigMap removed â€” no longer exists.

---

## Troubleshooting

- **Namespace stuck Terminating** â†’ `kubectl get ns <namespace> -o yaml` â€” check `spec.finalizers`; also check if any objects inside still have finalizers with `kubectl get all -n <namespace>`; common culprit is a CRD deleted before its custom resources were cleaned up
- **Object stuck after patch** â†’ you may have multiple finalizers; the patch sets to `[]` which clears all; if the object is still stuck, re-read it to confirm the finalizers field is actually empty
- **"Cannot delete resource" RBAC error** â†’ you need `patch` verb on the resource, not just `delete`; finalizer clearing requires a patch
- **Controller keeps re-adding finalizer** â†’ the controller is still running and re-adding its finalizer after you clear it; disable or delete the controller first

---

## Learning objective

- Explain what a finalizer is and why it blocks deletion.
- Walk through the full lifecycle: apply with finalizer â†’ delete â†’ stuck â†’ patch to release.
- Describe when it is and is not safe to force-clear a finalizer.

## Why this matters

Every Kubernetes operator â€” cert-manager, Argo CD, operators for databases and message queues â€” uses finalizers to ensure cleanup happens before objects are removed. When those controllers misbehave or are deleted unexpectedly, the objects they owned get stuck. Knowing how to diagnose and unstick them prevents "the namespace won't delete" from becoming an hours-long incident.

---

## Video close â€” fast validation

**What happens when you run this:**
One-liner cleanup path â€” apply, show finalizer, then delete and patch in one step.

**Say:**
Here's the compact version you'd use in a real recovery situation. Apply the object, confirm the finalizer, then chain the delete and patch together. After the patch the object disappears.

```bash
kubectl apply -f yamls/finalizer-demo.yaml
kubectl get cm finalizer-demo -n default -o yaml | grep -E 'finalizers:|deletionTimestamp:' || true
kubectl delete cm finalizer-demo -n default --wait=false 2>/dev/null
kubectl patch cm finalizer-demo -n default \
  -p '{"metadata":{"finalizers":[]}}' --type=merge 2>/dev/null || true
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/finalizer-demo.yaml` | ConfigMap with a finalizer |
| `yamls/failure-troubleshooting.yaml` | Stuck Terminating objects and namespace cleanup |

---

## Next

[2.1.2.8 Owners and dependents](../10-owners-and-dependents/README.md)
