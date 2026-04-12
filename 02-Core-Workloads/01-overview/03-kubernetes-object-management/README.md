# Kubernetes Object Management — teaching transcript

## Intro

Alright — this lesson is about the single most important habit in Kubernetes: using `kubectl apply` instead of `kubectl create`.

The difference is not just syntax. `create` is imperative — it sends a command and fails if the object already exists. `apply` is declarative — it sends desired state and the API server reconciles. Run it once or run it a hundred times: the result is always the same object matching your manifest. That's the property that makes GitOps, CI/CD, and safe re-deployments possible.

In this lesson you apply a manifest, see what it creates, and then practice the cleanup pattern you'll use at the end of every lab.

**Prerequisites:** [Part 1](../../01-Local-First-Operations/README.md).

**Teaching tip:** `scripts/object-management-demo.sh` header describes the exact API calls made.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/02-Core-Workloads/01-overview/03-kubernetes-object-management"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  [ Step 1 ]              [ Step 2 ]
  Apply demo       →      Validate + delete
  manifest                (cleanup)
```

**Say:**

Two stages. Apply the manifest and see what it creates. Then validate and clean up.

---

## Step 1 — Apply the demo manifest

**What happens when you run this:**
`chmod +x scripts/*.sh` makes scripts executable. `object-management-demo.sh` runs `kubectl apply -f yamls/object-management-demo.yaml`, which creates namespace `object-management-demo` and a Deployment inside it. Declarative — safe to run again; the second run will show `unchanged`.

**Say:**
Watch the output carefully. The first time you run `apply`, you see `created`. Run it again immediately and you see `unchanged`. That's the declarative contract — apply describes what you want, not what to do.

**Run:**

```bash
cd "$COURSE_DIR/02-Core-Workloads/01-overview/03-kubernetes-object-management"
chmod +x scripts/*.sh
./scripts/object-management-demo.sh
```

**Expected:**
`namespace/object-management-demo created` (or unchanged), `deployment.apps/demo-app created` (or unchanged).

---

## Step 2 — Inspect what was created

**What happens when you run this:**
`kubectl get deploy,pods -n object-management-demo -o wide` lists the Deployment and its Pods with node placement — read-only.

**Say:**
The Deployment created a ReplicaSet, the ReplicaSet created Pods. I didn't create the ReplicaSet or Pods directly — the Deployment controller did, based on the spec I applied. That's the reconciliation loop in action.

**Run:**

```bash
kubectl get deploy,pods -n object-management-demo -o wide
```

**Expected:**
One Deployment available; one or more Pods `Running`.

---

## `apply` vs `create` — when to use which

**`kubectl apply`** — use this for everything managed by manifests. It is:
- Idempotent (safe to re-run)
- Merge-based (only changes what's different)
- Trackable (stores last-applied configuration in an annotation)
- The right tool for GitOps pipelines

**`kubectl create`** — use this for one-off imperatives: generating a base manifest with `--dry-run=client -o yaml`, or testing something quickly you plan to delete immediately.

**`kubectl create` fails if the object exists.** `kubectl apply` does not. In a CI/CD pipeline, `create` will break the first time a re-run hits an existing resource. `apply` handles it gracefully.

---

## Troubleshooting

- **`apply` returns error about immutable field** → you changed a field that cannot be updated in place (e.g. a Pod's `spec.containers[].name`); delete and re-apply, or update only mutable fields
- **Deployment available but pod CrashLoops** → `kubectl logs <pod> -n object-management-demo` — the app itself is failing, not the manifest
- **`object-management-demo.sh` fails** → run `chmod +x scripts/*.sh` first; script needs execute permission
- **Namespace stuck Terminating** → a finalizer is blocking deletion; check `kubectl get ns object-management-demo -o yaml | grep finalizers`

---

## Learning objective

- Explain the difference between declarative `apply` and imperative `create`.
- Apply a manifest, verify the created objects, and delete via manifest.
- Describe why `apply` is preferred in automated pipelines.

## Why this matters

Every Kubernetes team eventually hits a CI/CD pipeline that breaks because someone used `create` instead of `apply`. Understanding the difference — and building the habit of declarative management from day one — prevents an entire class of "works on first deploy, breaks on re-deploy" failures.

---

## Video close — fast validation

**What happens when you run this:**
Recap view then delete the demo manifest — removes the namespace and all contents.

**Say:**
I always clean up lab resources at the end of a lesson. `kubectl delete -f` with the same manifest that created the objects is the cleanest approach — it deletes exactly what the manifest created, no more. I add `--ignore-not-found` and `|| true` on cleanup so a second recording take does not fail if the namespace is already gone.

```bash
kubectl get deploy,pods -n object-management-demo
kubectl delete -f yamls/object-management-demo.yaml --ignore-not-found 2>/dev/null || true
```

**Expected:**
Objects deleted; namespace gone after a few seconds.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/object-management-demo.sh` | Apply + get |
| `yamls/object-management-demo.yaml` | Demo namespace + Deployment |
| `yamls/failure-troubleshooting.yaml` | Apply / immutable field issues |

---

## Next

[2.1.2.2 Object names and IDs](../04-object-names-and-ids/README.md)
