# 2.3 Containers — teaching transcript

## Intro

If you only ever think of a container as “an image string in YAML,” you will be surprised by production behavior. Pulls repeat or skip based on **imagePullPolicy**. Supply chain and registry outages push teams toward **digests** instead of floating tags. Private registries need **imagePullSecrets**. Sandboxing and compliance show up as **RuntimeClass**. Graceful shutdown depends on **lifecycle hooks** and **termination grace**. Under all of it, **kubelet** talks to a real runtime through **CRI**. This module walks those layers in order so the Pod spec you write matches what actually runs on the node.

**Prerequisites:** [Part 1](../../part-1-getting-started/README.md); [2.1 Overview](../2.1-overview/README.md) and [2.2 Cluster architecture](../2.2-cluster-architecture/README.md) help but are not strict gates.

**Teaching tip:** Each subsection has **What happens when you run this** before commands. The only helper script is **`inspect-cri-endpoint.sh`** (2.3.5), with **WHAT THIS DOES WHEN YOU RUN IT** in its header — run it on a **Linux node** when possible.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/part-2-concepts/2.3-containers"
```

> If you set `COURSE_DIR` earlier this session, skip the export and just `cd`.

## Flow of this lesson

```
  [ 2.3.1 Images ]  →  [ 2.3.2 Environment ]  →  [ 2.3.3 RuntimeClass ]
         │                      │                        │
         └──────────────────────┴────────────────────────┘
                                  │
                                  ▼
  [ 2.3.4 Hooks ]  →  [ 2.3.5 CRI / crictl ]
```

**Say:**

We start with how images are referenced and pulled, then how environment and downward API reach the process, then optional isolation via RuntimeClass. Hooks sit on the boundary of startup and shutdown, and we end at the socket where kubelet hands work to containerd or CRI-O.

## From Pod spec to running container

```
  Declared in Pod
  ┌─────────────────────────────┐
  │ Pod                         │
  │   └── Container             │
  │         ├── image + pullPolicy
  │         ├── command / args / env / hooks
  │         └── (Pod-level) runtimeClassName (optional)
  └─────────────────────────────┘
           │
           ▼
  API server stores desired state
           │
           ▼
  kubelet watches and reconciles
           │
           ▼
  CRI (gRPC) ──▶ container runtime
           │
           ▼
  Processes inside container namespaces
```

**Say:**

The diagram is the spine: everything in the left box is declaration; kubelet plus CRI turns it into processes. RuntimeClass is a Pod field that changes which handler the runtime uses when the pod is scheduled.

---

## Step 1 — Open the 2.3 module folder

**What happens when you run this:**

`cd` moves into `2.3-containers`. `pwd` confirms the path.

**Say:**

I stand here so relative paths to **2.3.1** through **2.3.5** match what you see in the repo.

**Run:**

```bash
cd "$COURSE_DIR/part-2-concepts/2.3-containers"
pwd
```

**Expected:**

Path ending with `2.3-containers`.

---

## Step 2 — Work children in order (reading step)

**What happens when you run this:**

You open each child README and run its lab commands on a cluster whose API you can reach.

**Say:**

I do not skip **2.3.1** — image policy confusion causes more incident noise than almost any other single field.

**Run:**

_(Open [2.3.1 Images](2.3.1-images/README.md) first.)_

**Expected:**

You are ready to begin **2.3.1**.

---

## Troubleshooting

- **`kubectl: command not found` before any 2.3 lab** → finish Part 1 local cluster or fix `PATH`
- **`Unable to connect to the server`** → `kubectl config current-context`; confirm cluster is up
- **`Forbidden` applying manifests** → use a namespace you can write to or a lab context with create rights
- **Child lesson pod stays `Pending`** → `kubectl describe pod` for events; RuntimeClass or image pull issues differ by lesson
- **Script in 2.3.5 shows no sockets from your laptop** → SSH to a Linux node and run it there — that is expected

---

## Learning objective

- Drew the path from Pod fields (image, env, hooks, RuntimeClass) through kubelet and CRI to running processes.
- Located each subsection README under `$COURSE_DIR` and ran the module wrap commands when a cluster exists.

## Why this matters

Workloads fail in ways that only make sense when you know who pulls images, who injects env, and who owns the socket under `/run/...`. This module is the vocabulary for those escalations.

## Video close — fast validation

**What happens when you run this:**

Nodes, a sample of pods cluster-wide, and RuntimeClass objects if the API serves that resource — all read-only.

**Say:**

Three quick reads: capacity and placement, workload snapshot, whether any RuntimeClasses are defined on this cluster.

**Run:**

```bash
kubectl get nodes -o wide
kubectl get pods -A | head -n 25
kubectl get runtimeclass 2>/dev/null || true
```

**Expected:**

Node list; first ~25 pod rows; RuntimeClass list or empty output without failing the shell.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `2.3.1-images/yamls/` | Pull policy demo |
| `2.3.5-container-runtime-interface-cri/scripts/inspect-cri-endpoint.sh` | Socket scan + `crictl info` |

---

## Children (work in order)

- [2.3.1 Images](2.3.1-images/README.md)
- [2.3.2 Container environment](2.3.2-container-environment/README.md)
- [2.3.3 Runtime class](2.3.3-runtime-class/README.md)
- [2.3.4 Container lifecycle hooks](2.3.4-container-lifecycle-hooks/README.md)
- [2.3.5 Container Runtime Interface (CRI)](2.3.5-container-runtime-interface-cri/README.md)

---

## Next module

[2.4 Workloads](../2.4-workloads/README.md) (suggested course order).
