# 2.1.2 Objects In Kubernetes â€” teaching transcript

## Intro

Kubernetes **objects** are declarative records: metadata, spec, status, ownership, and lifecycle hooks (finalizers). This module breaks that down into teachable slices.

**Prerequisites:** [Part 1](../../part-1-getting-started/README.md).

**Teaching tip:** Run subsection lessons **in order** when possible; each has **What happens** before commands.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/02-Core-Workloads/01-overview/02-objects-in-kubernetes"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Object lifecycle (mental model)

```
  Manifest YAML
       â”‚
       â–¼ kubectl apply
  API server (validates + stores)
       â”‚                    â–²
       â–¼                    â”‚ reconcile
     etcd            Controllers
  (desired state)
       â”‚
       â–¼
  Node agents (kubelet)
```

**Say:**

You write YAML, `kubectl apply` sends desired state, the API persists it in etcd, controllers reconcile toward that spec, and kubelet plus the runtime make it real on nodes. Every subsection in **2.1.2** zooms into one slice of that story.

---

## Step 1 â€” Open this module directory

**What happens when you run this:**

`cd` moves into `../02-objects-in-kubernetes`. `pwd` confirms.

**Say:**

Child lessons live in numbered folders under here; I start from this path when I mention relative YAML paths.

**Run:**

```bash
cd "$COURSE_DIR/02-Core-Workloads/01-overview/02-objects-in-kubernetes"
pwd
```

**Expected:**

Path ending with `../02-objects-in-kubernetes`.

---

## Step 2 â€” Start subsection 2.1.2.1 (reading step)

**What happens when you run this:**

You open the first child README â€” no API calls until that file tells you to run them.

**Say:**

I begin with object management (`apply` vs `create`) because every later subsection assumes that habit.

**Run:**

_(Open [2.1.2.1 Kubernetes object management](../03-kubernetes-object-management/README.md).)_

**Expected:**

You are reading lesson **2.1.2.1**.

---

## Troubleshooting

- **`cd` fails** â†’ re-export `COURSE_DIR` to your actual clone path
- **Skipping sub-lessons** â†’ later lessons assume labels, namespaces, and finalizers vocabulary from earlier files
- **`kubectl apply` errors on shared cluster** â†’ you may lack RBAC; use a personal lab context
- **Cleanup missed between videos** â†’ many lessons end with `kubectl delete -f`; run the Video close block before re-recording

---

## Learning objective

- Drew the apply â†’ API â†’ etcd â†’ controllers â†’ kubelet lifecycle in one diagram.
- Located every subsection README under `$COURSE_DIR` for sequential study.
- Ran the cross-module labels demo using paths rooted at `$COURSE_DIR`.

## Why this matters

Objects are how Kubernetes stores intent. If metadata concepts are fuzzy, every workload and networking lesson feels like memorization instead of structure.

## Video close â€” fast validation

**What happens when you run this:**

Applies the **2.1.2.3** demo manifest, lists pod labels, deletes the demo. `2>/dev/null` and `--ignore-not-found` keep repeats quiet.

**Say:**

I reuse the labels demo path for a quick horizontal integration: apply, show labels cluster-wide for a few lines, delete. The cleanup line uses `--ignore-not-found` so a second take does not fail.

**Run:**

```bash
cd "$COURSE_DIR/02-Core-Workloads/01-overview/02-objects-in-kubernetes"
kubectl apply -f ../05-labels-and-selectors/yamls/labels-and-selectors-demo.yaml
kubectl get pods --show-labels -A | head -n 30
kubectl delete -f ../05-labels-and-selectors/yamls/labels-and-selectors-demo.yaml --ignore-not-found 2>/dev/null || true
```

**Expected:**

Objects create; label columns appear; delete succeeds or is ignored.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `../03-kubernetes-object-management/` | Declarative apply habit |
| `../04-object-names-and-ids/` | Names, UIDs, `generateName` |
| `../09-finalizers/` | Blocking deletion |
| `../12-storage-versions/` | API storage versions |

---

## Children (work in order)

- [2.1.2.1 Kubernetes object management](../03-kubernetes-object-management/README.md)
- [2.1.2.2 Object names and IDs](../04-object-names-and-ids/README.md)
- [2.1.2.3 Labels and selectors](../05-labels-and-selectors/README.md)
- [2.1.2.4 Namespaces](../06-namespaces/README.md)
- [2.1.2.5 Annotations](../07-annotations/README.md)
- [2.1.2.6 Field selectors](../08-field-selectors/README.md)
- [2.1.2.7 Finalizers](../09-finalizers/README.md)
- [2.1.2.8 Owners and dependents](../10-owners-and-dependents/README.md)
- [2.1.2.9 Recommended labels](../11-recommended-labels/README.md)
- [2.1.2.10 Storage versions](../12-storage-versions/README.md)

---

## Next

[2.1.3 The Kubernetes API](../13-the-kubernetes-api/README.md)
