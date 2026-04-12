# Storage Versions — teaching transcript

## Intro

Kubernetes serves objects in multiple API versions, but stores them in etcd in exactly one.

That stored version is called the **storage version**. When you `kubectl apply` using `apps/v1`, the API server accepts it. When you `kubectl get` using an older version like `extensions/v1beta1` (on clusters that still serve it), the API server reads from etcd, converts to the requested version, and returns it. The data in etcd doesn't change — only the view you get.

This matters most during Kubernetes upgrades. When you upgrade the cluster, some API versions are deprecated and removed. If your manifests use a removed version, `kubectl apply` fails. But more subtly, if objects were stored in a deprecated version and you upgrade past it, etcd migration must happen — either automatically by the API server, or manually with tools like `kubectl convert`.

Understanding storage versions helps you anticipate and prevent "my deployments broke after the upgrade" situations.

**Prerequisites:** [Part 1](../../01-Local-First-Operations/README.md).

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/02-Core-Workloads/01-overview/12-storage-versions"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  [ Step 1 ]                  [ Step 2 ]
  Apply notes      →          Inspect API versions
  ConfigMap                   via kubectl
```

**Say:**

Two steps: apply the storage version notes as a ConfigMap so they live in the cluster, then use kubectl's raw API access to see the actual version information served by the API server.

---

## Step 1 — Apply the storage version notes

**What happens when you run this:**
`kubectl apply -f yamls/storage-version-notes.yaml` creates or updates ConfigMap `storage-version-notes` in `kube-system` with embedded explanation text. This is documentation in the cluster, not live cert or version data.

**Say:**
I store these notes in `kube-system` so they're accessible to any engineer with cluster access. If your cluster's RBAC blocks writes to `kube-system`, apply to another namespace instead — the content is the same.

> **RBAC note:** The `Run` block below writes a ConfigMap to **`kube-system`**. On many managed clusters your user is **Forbidden**. If that happens, edit `yamls/storage-version-notes.yaml` so `metadata.namespace` is **`default`** (or another namespace you can write), or skip the apply and read the file from git.

**Run:**

```bash
cd "$COURSE_DIR/02-Core-Workloads/01-overview/12-storage-versions"
kubectl apply -f yamls/storage-version-notes.yaml
kubectl get cm storage-version-notes -n kube-system \
  -o jsonpath='{.data.notes}' | head -n 5
```

**Expected:**
ConfigMap created or unchanged; first five lines of the notes text printed. If you get `Forbidden`, run `kubectl apply -f yamls/storage-version-notes.yaml -n default` instead.

---

## Step 2 — Inspect API versions

**What happens when you run this:**
`kubectl api-versions` lists every API group and version the server currently serves — read-only. `kubectl get --raw /apis/apps/v1` fetches the raw API group definition JSON, showing what resources the `apps/v1` group exposes.

**Say:**
`kubectl api-versions` is how you confirm what your cluster actually serves right now. Before an upgrade, I run this, save the output, then compare after the upgrade. Any version in the pre-upgrade list that's gone post-upgrade means manifests using that version will break. The `--raw /apis/apps/v1` call shows the JSON underneath — it lists resources, verbs, and the storage version marker.

**Run:**

```bash
kubectl api-versions | head -n 20
kubectl get --raw /apis/apps/v1 2>/dev/null | head -c 120; echo
```

**Expected:**
First command: list of `group/version` strings. Second command: first 120 chars of JSON with `kind: APIResourceList`.

---

## API version deprecation timeline — what to watch for

Kubernetes follows a deprecation policy: deprecated API versions are supported for at least two minor releases before removal. Common migrations teams have gone through:

| Removed version | Replacement | Removed in |
|-----------------|-------------|------------|
| `extensions/v1beta1` Deployment | `apps/v1` | K8s 1.16 |
| `apps/v1beta1` Deployment | `apps/v1` | K8s 1.16 |
| `networking.k8s.io/v1beta1` Ingress | `networking.k8s.io/v1` | K8s 1.22 |
| `policy/v1beta1` PodSecurityPolicy | removed entirely | K8s 1.25 |
| `autoscaling/v2beta2` HPA | `autoscaling/v2` | K8s 1.26 |

**Before every upgrade:** run `kubectl api-versions` and compare to the deprecation notices in the release notes for the target version. Tools like `pluto` (fair-source) can scan your manifests and Helm charts for deprecated API usage.

---

## Troubleshooting

- **`Forbidden` on `kube-system` write** → change `namespace: kube-system` to `namespace: default` in the YAML, or apply with `-n default`; the content is unchanged
- **`api-versions` missing a version after upgrade** → any manifest using that version will fail; update manifests to use the replacement version listed in K8s release notes
- **`kubectl convert` not available** → it's a separate plugin since K8s 1.20; install with `kubectl krew install convert`; converts manifest files between API versions without hitting the cluster
- **Object stuck in storage with old version** → the API server automatically serves the stored version converted to the requested version; if a migration is needed (rare), it happens on-read and re-write; check the K8s Storage Version Migration guide for the rare cases requiring explicit migration

---

## Learning objective

- Explain the difference between a served API version and the storage version in etcd.
- Use `kubectl api-versions` and `kubectl get --raw` to inspect what the cluster serves.
- Name three API versions that have been removed and their replacements.

## Why this matters

API version deprecations cause some of the most confusing upgrade failures: everything works fine on 1.21, then after upgrading to 1.22 your CI pipeline starts failing with "no matches for kind Ingress in version networking.k8s.io/v1beta1". This is always preventable with a pre-upgrade audit. Storage versions are the mechanism that makes the upgrade possible at all — understanding them makes the audit make sense.

---

## Video close — fast validation

**What happens when you run this:**
API versions list; raw group JSON snippet; delete the ConfigMap.

**Say:**
`kubectl api-versions` is a quick cluster health diagnostic — I can see at a glance what API surface this cluster exposes. Then I clean up the ConfigMap. If you want to keep the notes, skip the delete.

```bash
kubectl api-versions | head -n 20
kubectl get --raw /apis/apps/v1 2>/dev/null | head -c 120; echo
kubectl delete cm storage-version-notes -n kube-system --ignore-not-found
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/storage-version-notes.yaml` | Embedded explanation ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Version migration and RBAC denial hints |

---

## Next

[2.1.3 The Kubernetes API](../../13-the-kubernetes-api/README.md)
