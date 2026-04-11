# 2.1 Overview

## Intro

This module builds the mental model for how Kubernetes stores desired state, how the API exposes it, and how `kubectl` reads and changes that state without surprises.

**Prerequisites:** [Part 1](../../part-1-getting-started/README.md) — you need a reachable cluster and working `kubectl`.

**Teaching tip:** Sub-lessons use **What happens when you run this** before command blocks; each `scripts/*.sh` repeats the behavior in a file header.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/part-2-concepts/2.1-overview"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  You
   │
   ▼
 kubectl
   │
   ▼
 API server ──────────────── etcd (desired state)
   │    ▲
   │    │
   ▼    │
 Controllers (reconcile loops)
   │
   ▼
 kubelet on each node
   │
   ▼
 CRI / container runtime
```

**Say:**

You speak to the cluster through `kubectl`. The API server validates requests and stores objects in etcd. Controllers watch the API and nudge reality toward spec. Kubelet on each node talks to the container runtime so pods become real processes. This module names each box and then walks the API and `kubectl` tools that sit in front of it.

---

## Step 1 — Open the 2.1 overview folder

**What happens when you run this:**

`cd` moves into `2.1-overview`. `pwd` prints the path.

**Say:**

I anchor here before opening **2.1.1** so relative links to children stay consistent on camera.

**Run:**

```bash
cd "$COURSE_DIR/part-2-concepts/2.1-overview"
pwd
```

**Expected:**

Path ending with `2.1-overview`.

---

## Step 2 — Work the child lessons in order (reading step)

**What happens when you run this:**

You open each README below and run its commands on your cluster.

**Say:**

I read **2.1.1** through **2.1.4** in order — components, objects, API discovery, then `kubectl` habits.

**Run:**

_(Open the **Children** links.)_

**Expected:**

You are ready to start [2.1.1 Kubernetes components](2.1.1-kubernetes-components/README.md).

---

## Troubleshooting

- **`cd: ... 2.1-overview: No such file or directory`** → fix `COURSE_DIR` to your clone root
- **`kubectl` commands fail with `Forbidden`** → some lessons write to `kube-system`; use a lab cluster with admin rights or change manifests to `default` as each lesson notes
- **Skipping **2.1** before workloads in Part 2** → allowed, but later lessons assume you know API groups and `kubectl` output flags
- **`api-resources` empty or tiny** → check `kubectl cluster-info`; aggregator or extension apiservers may be down
- **Lost between objects vs API lessons** → objects (**2.1.2**) are data; API (**2.1.3**) is how you list and mutate that data

---

## Learning objective

- Stated how `kubectl`, the API server, etcd, controllers, kubelet, and the runtime fit together.
- Navigated the **2.1** child lessons in order and located scripts or YAML each references.
- Ran the module wrap commands below as a read-only sanity check.

## Why this matters

Every later concept lesson assumes you can picture where state lives and which component enforces it. Spending time here prevents magical thinking when something `Pending` or `CrashLoopBackOff` appears.

## Video close — fast validation

**What happens when you run this:**

Confirms API surface, namespaces, and a short cross-namespace listing — all read-only.

**Say:**

Three quick queries: resource names for core types, namespaces, then a shallow `get all` across namespaces.

**Run:**

```bash
kubectl api-resources | grep -E "^configmaps|^pods|^deployments" || true
kubectl get ns
kubectl get all -A | head -n 20
```

**Expected:**

Matching api-resource rows; namespace list; first lines of cross-namespace objects.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `2.1.1-kubernetes-components/` | Control-plane visibility script + YAML |
| `2.1.2-objects-in-kubernetes/` | Object metadata subsection lessons |
| `2.1.3-the-kubernetes-api/` | Discovery / raw API exploration |
| `2.1.4-the-kubectl-command-line-tool/` | Context and formatting habits |

---

## Children (work in order)

1. [2.1.1 Kubernetes components](2.1.1-kubernetes-components/README.md)
2. [2.1.2 Objects in Kubernetes](2.1.2-objects-in-kubernetes/README.md) — subsection lessons 2.1.2.1–2.1.2.10 inside
3. [2.1.3 The Kubernetes API](2.1.3-the-kubernetes-api/README.md)
4. [2.1.4 The kubectl command-line tool](2.1.4-the-kubectl-command-line-tool/README.md)

---

## Next module

Continue to [2.2 Cluster architecture](../2.2-cluster-architecture/README.md).
