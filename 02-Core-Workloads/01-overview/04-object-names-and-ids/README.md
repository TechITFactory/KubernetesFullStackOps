# 2.1.2.2 Object Names and IDs â€” teaching transcript

## Intro

Every Kubernetes object has two identifiers: a **name** and a **UID**.

The name is what you write in your manifest â€” it's scoped to a namespace and a resource type, human-readable, and reusable after deletion. The UID is assigned by the API server the moment an object is created â€” it's cluster-wide unique, immutable, and never reused even if you delete and recreate the object with the same name.

This distinction matters for one specific reason: **ownerReferences** use UIDs, not names. When a Deployment owns a ReplicaSet, the reference is by UID. If you delete and recreate the Deployment with the same name, the new Deployment gets a new UID, and the old ReplicaSet becomes an orphan. Understanding this prevents confusion during rolling updates and namespace cleanup.

This lesson also covers `generateName` â€” a Kubernetes feature that lets the API server assign a unique suffix to your object's name, useful for Jobs and batch workloads.

**Prerequisites:** [Part 1](../../part-1-getting-started/README.md).

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/02-Core-Workloads/01-overview/04-object-names-and-ids"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  [ Step 1 ]                  [ Step 2 ]
  Create with         â†’       Read name + UID
  generateName                with custom-columns
```

**Say:**

Two steps: create an object using `generateName` to see how name generation works, then read both the name and UID side by side.

---

## Step 1 â€” Create with `generateName`

**What happens when you run this:**
`kubectl create -f yamls/object-name-and-uid-demo.yaml` sends the manifest to the API server. The manifest uses `generateName: generated-object-` instead of `name:` â€” the API server appends a random 5-character suffix and creates the object. Uses `create` (not `apply`) because `generateName` objects are intentionally unique each time.

**Say:**
Notice the manifest uses `generateName`, not `name`. Every time you `create` from this manifest, you get a new object with a different suffix â€” `generated-object-xk9p2`, `generated-object-r7mbn`, and so on. This is how Kubernetes creates Pod names from a ReplicaSet template: the ReplicaSet spec has `generateName` and each Pod gets its own unique suffix.

**Run:**

```bash
cd "$COURSE_DIR/02-Core-Workloads/01-overview/04-object-names-and-ids"
kubectl create -f yamls/object-name-and-uid-demo.yaml
```

**Expected:**
`configmap/generated-object-<suffix> created` â€” the suffix is random.

---

## Step 2 â€” Read name and UID

**What happens when you run this:**
`kubectl get` with `-l` selector and custom columns prints both `metadata.name` and `metadata.uid` side by side. Read-only.

**Say:**
`custom-columns` is one of the most useful output formats in kubectl. Instead of getting everything, I specify exactly which fields I want. Here I'm comparing name â€” which I partially chose â€” and UID â€” which the API server assigned and I cannot change.

**Run:**

```bash
kubectl get cm -n default -l training.k8sops.io/lesson=object-names-and-ids \
  -o custom-columns=NAME:.metadata.name,UID:.metadata.uid
```

**Expected:**
One or more rows with `generated-object-<suffix>` in NAME and a UUID in UID.

---

## Name vs UID â€” the practical difference

**Name:**
- Scoped to namespace + resource type (two Deployments in different namespaces can share a name)
- Set by you or by `generateName`
- Reusable after deletion
- What you use in `kubectl get`, manifest files, and cross-references between objects in the same namespace

**UID:**
- Cluster-wide unique
- Assigned by the API server at creation
- Never reused â€” even if you delete and recreate an object with the same name, it gets a new UID
- What `ownerReferences` use internally

**The ownership implication:** if you delete a Deployment and recreate it with the same name, the old ReplicaSet had an `ownerReference` pointing at the old UID. The new Deployment has a new UID. The old ReplicaSet becomes an orphan â€” it still exists and may still have pods. Garbage collection eventually cleans it up, but there's a window where you can have duplicate pods.

---

## Troubleshooting

- **`create` fails with "already exists"** â†’ the previous lesson's objects may still be running; delete with `kubectl delete cm -n default -l training.k8sops.io/lesson=object-names-and-ids` then retry
- **`generateName` objects multiply on re-run** â†’ `create` is not idempotent; each run makes a new object; delete all with the label selector before re-recording
- **UID column shows `<none>`** â†’ check the jsonpath: `.metadata.uid` â€” confirm the object is fully created (not stuck pending)
- **Cannot find object** â†’ confirm namespace (`-n default`) and label selector match the manifest

---

## Learning objective

- Explain the difference between `metadata.name` and `metadata.uid`.
- Create an object using `generateName` and read its generated name and UID.
- Describe why ownerReferences use UIDs and why this matters during Deployment recreations.

## Why this matters

When a namespace cleanup hangs, when pods linger after a Deployment delete, or when `kubectl get` returns unexpected objects â€” UIDs and ownerReferences are almost always involved. Understanding this layer makes garbage collection and orphan cleanup predictable instead of mysterious.

---

## Video close â€” fast validation

**What happens when you run this:**
Delete any existing objects from this lesson, recreate one, show its full YAML header, then delete again as cleanup.

**Say:**

If I am re-recording this closing block, I always run the delete line first because `kubectl create` errors when the ConfigMap from an earlier take still exists. The delete uses `--ignore-not-found` so it is harmless when nothing is there. After a fresh `create`, I show the top of the object YAML so you see `metadata.uid` next to `name` and `creationTimestamp`, then I delete the label again to leave the cluster tidy.

```bash
kubectl delete cm -n default -l training.k8sops.io/lesson=object-names-and-ids --ignore-not-found 2>/dev/null || true
kubectl create -f yamls/object-name-and-uid-demo.yaml
kubectl get cm -n default -l training.k8sops.io/lesson=object-names-and-ids -o yaml | head -n 40
kubectl delete cm -n default -l training.k8sops.io/lesson=object-names-and-ids --ignore-not-found 2>/dev/null || true
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/object-name-and-uid-demo.yaml` | `generateName` demo ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Name / UID / already-exists issues |

---

## Next

[2.1.2.3 Labels and selectors](../05-labels-and-selectors/README.md)
