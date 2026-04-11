# 2.1.2.4 Namespaces â€” teaching transcript

## Intro

Namespaces are Kubernetes's first layer of isolation.

They scope names â€” two teams can each have a Deployment named `api` as long as they're in different namespaces. They scope RBAC â€” a RoleBinding in namespace `team-a` gives permissions only within that namespace. They scope quotas â€” a ResourceQuota on namespace `team-b` caps what that team can consume without touching anyone else.

What namespaces do **not** do: they don't isolate network traffic. Pods in different namespaces can reach each other by default. If you need network isolation between namespaces, you need NetworkPolicies â€” that's covered in Part 2's networking section.

Understanding namespace scope also explains a common `kubectl` confusion: why does `kubectl get pods` show nothing when there are pods running? Because `kubectl` defaults to the namespace in your current context, not `--all-namespaces`. This lesson makes that behavior predictable.

**Prerequisites:** [Part 1](../../part-1-getting-started/README.md).

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/02-Core-Workloads/01-overview/06-namespaces"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  [ Step 1 ]            [ Step 2 ]
  Apply namespace  â†’    Inspect labels
  manifest              and scope
```

**Say:**

Two steps â€” apply the namespace manifest and then inspect it. The lesson is short because namespaces themselves are simple objects; the depth is in understanding what they scope and what they don't.

---

## Step 1 â€” Apply the namespace manifest

**What happens when you run this:**
`kubectl apply -f yamls/namespace-demo.yaml` creates namespace `overview-lab` with labels set. Declarative; safe to re-run.

**Say:**
Namespaces are just Kubernetes objects â€” you create them with a manifest like anything else. The labels on a namespace are important: they're how Pod Security Standards labels work, how network policies can target namespaces, and how monitoring tools group workloads. An unlabeled namespace is a namespace you can't filter on later.

**Run:**

```bash
cd "$COURSE_DIR/02-Core-Workloads/01-overview/06-namespaces"
kubectl apply -f yamls/namespace-demo.yaml
```

**Expected:**
`namespace/overview-lab created` or unchanged.

---

## Step 2 â€” Inspect the namespace

**What happens when you run this:**
`kubectl get ns overview-lab --show-labels` lists the namespace with its label columns â€” read-only.

**Say:**
Two things I check on every namespace: the labels (for PSS, quota, and tooling) and whether there's a `ResourceQuota` and `LimitRange` on it. Without quota, a single runaway workload can consume all cluster resources. We covered setting those up in Part 1's dev-local workspace â€” the same pattern applies to any production namespace.

**Run:**

```bash
kubectl get ns overview-lab --show-labels
```

**Expected:**
Namespace listed with `purpose=training` (or whatever labels your YAML set).

---

## Namespace scope cheat sheet

| Thing | Scoped by namespace? |
|-------|---------------------|
| Pod, Deployment, Service, ConfigMap | âœ… Yes |
| PersistentVolumeClaim | âœ… Yes |
| Role, RoleBinding | âœ… Yes |
| Node, PersistentVolume, StorageClass | âŒ No â€” cluster-scoped |
| ClusterRole, ClusterRoleBinding | âŒ No â€” cluster-scoped |
| Network traffic between pods | âŒ No â€” needs NetworkPolicy |

**Default namespace:** If your `kubectl` context has no namespace set, commands hit `default`. You can change the default with:
```bash
kubectl config set-context --current --namespace=overview-lab
```
Reset it with:
```bash
kubectl config set-context --current --namespace=default
```

---

## Troubleshooting

- **`kubectl get pods` returns nothing but pods exist** â†’ you're in the wrong namespace; add `-n <namespace>` or `-A` for all namespaces; check `kubectl config current-context`
- **Cannot delete namespace â€” stuck Terminating** â†’ something inside the namespace has a finalizer blocking cleanup; check `kubectl get all -n <namespace>` and `kubectl describe ns <namespace>` for finalizer info
- **`kubectl apply` in wrong namespace** â†’ if your manifest has no `namespace:` in `metadata`, it goes to the current context namespace; always set `metadata.namespace` in shared manifests
- **RBAC error in new namespace** â†’ Roles are namespace-scoped; a Role in `default` gives no permissions in `overview-lab`; create a matching Role and RoleBinding in each namespace where access is needed

---

## Learning objective

- Create a labeled namespace and explain what namespace scope applies to.
- Explain the difference between namespace-scoped and cluster-scoped resources.
- Describe what namespaces do not isolate and how to address that gap.

## Why this matters

Every production Kubernetes cluster uses namespaces to separate teams, environments, or services. Getting namespace scope wrong â€” thinking namespaces provide network isolation, or not labeling namespaces for PSS â€” creates security and operational gaps that are hard to fix later without disrupting running workloads.

---

## Video close â€” fast validation

**What happens when you run this:**
Read the namespace YAML, then delete it â€” cascades all contents.

**Say:**
`kubectl get ns -o yaml` shows the full namespace object including status. The `status.phase` field should be `Active`. Then I delete â€” `kubectl delete ns` cascades and removes everything inside it. This is why deleting a namespace is the nuclear option for cleanup. I append `2>/dev/null || true` on the delete so a second take does not fail when the namespace is already gone.

```bash
kubectl get ns overview-lab -o yaml | head -n 30
kubectl delete ns overview-lab --ignore-not-found 2>/dev/null || true
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/namespace-demo.yaml` | Labeled demo namespace |
| `yamls/failure-troubleshooting.yaml` | Context, finalizer, and scope issues |

---

## Next

[2.1.2.5 Annotations](../07-annotations/README.md)
