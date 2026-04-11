# 1.1 Learning Environment

## Intro

Before you run `kubectl` against real work, you need a **cluster on your machine** — no cloud account required for this module.

You will **either** use **Minikube (1.1.1)** **or** **Kind (1.1.2)** — pick one and stay on it. Then **1.1.3** adds a governed workspace namespace (`dev-local`) on top of whichever cluster you chose.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/part-1-getting-started/1.1-learning-environment"
```

> If you set `COURSE_DIR` in Part 0 or Part 1, skip the export and just `cd`.

## Flow of this lesson

```
  Need a local cluster
          │
          ▼
   ┌──────┴───────┐
   │   Pick one   │
   └──────┬───────┘
          │
    ┌─────┴──────┐
    │            │
    ▼            ▼
 1.1.1        1.1.2
 Minikube      Kind
 (single       (multi-node
  node,         in Docker,
  addons)       CI-style)
    │            │
    └─────┬──────┘
          ▼
    1.1.3 dev-local
      namespace
```

**Say:**

You only need one local stack. Pick Minikube if you want single-node with addons like Ingress. Pick Kind if you want multi-node inside Docker. Both paths meet in **1.1.3** to add quotas and a demo app in `dev-local`.

---

## Step 1 — Open the 1.1 folder

**What happens when you run this:**

`cd` moves into `1.1-learning-environment`. `pwd` prints the path.

**Say:**

I stand in the module folder so relative links to **1.1.1**–**1.1.3** match what you see on screen.

**Run:**

```bash
cd "$COURSE_DIR/part-1-getting-started/1.1-learning-environment"
pwd
```

**Expected:**

Path ending with `1.1-learning-environment`.

---

## Step 2 — Choose your lesson and continue

**What happens when you run this:**

You open exactly one of the child READMEs below — no cluster command until that lesson tells you to run it.

**Say:**

I commit to **1.1.1** or **1.1.2**, then I always do **1.1.3** on that same context so quotas and the whoami app land on the cluster I already built.

**Run:**

_(Open one primary lesson, then **1.1.3**.)_

**Expected:**

You are reading either [1.1.1 Minikube](1.1.1-minikube-setup-and-configuration/README.md) or [1.1.2 Kind](1.1.2-kind-kubernetes-in-docker/README.md), followed by [1.1.3 Local development clusters](1.1.3-local-development-clusters/README.md).

---

## Troubleshooting

- **Started both Minikube and Kind “just to compare”** → pick one context with `kubectl config use-context` before **1.1.3** or tear down the extra cluster to avoid accidental applies
- **`kubectl: command not found` before 1.1** → complete the installer steps inside **1.1.1** or **1.1.2** first
- **`dev-local` missing after 1.1.3** → re-run bootstrap from **1.1.3** on the correct context (`minikube` vs `kind-kfsops-kind`)
- **Docker not running (Kind)** → start Docker Desktop or the Linux daemon; Kind cannot create nodes without it
- **Minikube profile confusion** → this course uses profile `kfsops-minikube`; check `minikube profile list`

---

## Learning objective

- Chose **either** Minikube **or** Kind as the single local stack for the module.
- Described why **1.1.3** always follows the cluster lesson on the **same** kubectl context.
- Located the three child README paths from `$COURSE_DIR`.

## Why this matters

A stable local cluster plus a governed `dev-local` namespace mirrors how platform teams isolate teams on shared clusters — only the scale changes.

## Video close — fast validation

**What happens when you run this:**

Read-only checks after **1.1.3**: cluster info, namespace, quota objects, pods in `dev-local`. Add `--context kind-kfsops-kind` if you use Kind.

**Say:**

After **1.1.3**, I confirm the API answers, `dev-local` exists, and quota objects are bound before I move to Part 1.2.

**Run:**

```bash
kubectl cluster-info
kubectl get ns dev-local
kubectl get quota,limitrange -n dev-local
kubectl get pods -n dev-local -o wide
```

**Expected:**

`cluster-info` returns a URL; `dev-local` is `Active`; quota and limitrange rows exist; whoami (or demo) pods are `Running`.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `1.1.1-minikube-setup-and-configuration/` | Single-node Minikube track |
| `1.1.2-kind-kubernetes-in-docker/` | Multi-node Kind track |
| `1.1.3-local-development-clusters/` | `dev-local` workspace |

---

## Sections

| Lesson | Link | Choose if… |
|--------|------|------------|
| **1.1.1** | [Minikube setup](1.1.1-minikube-setup-and-configuration/README.md) | You want one node, addons (e.g. Ingress), familiar “minikube service” flow. |
| **1.1.2** | [Kind](1.1.2-kind-kubernetes-in-docker/README.md) | You want multi-node-in-Docker, fast spin-up, CI-like workflows. |
| **1.1.3** | [Local dev clusters / dev-local](1.1.3-local-development-clusters/README.md) | **After** 1.1.1 or 1.1.2 — quotas, limit ranges, demo app in `dev-local`. |

---

## Next

Open [1.1.1](1.1.1-minikube-setup-and-configuration/README.md) or [1.1.2](1.1.2-kind-kubernetes-in-docker/README.md), then [1.1.3](1.1.3-local-development-clusters/README.md). Continue with [1.2 Production environment](../1.2-production-environment/README.md) when your path requires Linux node setup.
