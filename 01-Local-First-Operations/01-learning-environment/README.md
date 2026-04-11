# 01 Learning Environment

## Intro

Before you run `kubectl` against real work, you need a **cluster on your machine** â€” no cloud account required for this module.

You will **either** use **Minikube (01.1)** **or** **Kind (01.2)** â€” pick one and stay on it. Then **03** adds a governed workspace namespace (`dev-local`) on top of whichever cluster you chose.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/01-learning-environment"
```

> If you set `COURSE_DIR` in Part 0 or Part 1, skip the export and just `cd`.

## Flow of this lesson

```
  Need a local cluster
          â”‚
          â–¼
   â”Œâ”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”
   â”‚   Pick one   â”‚
   â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”˜
          â”‚
    â”Œâ”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”
    â”‚            â”‚
    â–¼            â–¼
 01.1        01.2
 Minikube      Kind
 (single       (multi-node
  node,         in Docker,
  addons)       CI-style)
    â”‚            â”‚
    â””â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”˜
          â–¼
    03 dev-local
      namespace
```

**Say:**

You only need one local stack. Pick Minikube if you want single-node with addons like Ingress. Pick Kind if you want multi-node inside Docker. Both paths meet in **03** to add quotas and a demo app in `dev-local`.

---

## Step 1 â€” Open the 01 folder

**What happens when you run this:**

`cd` moves into `01-learning-environment`. `pwd` prints the path.

**Say:**

I stand in the module folder so relative links to **01.1**â€“**03** match what you see on screen.

**Run:**

```bash
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/01-learning-environment"
pwd
```

**Expected:**

Path ending with `01-learning-environment`.

---

## Step 2 â€” Choose your lesson and continue

**What happens when you run this:**

You open exactly one of the child READMEs below â€” no cluster command until that lesson tells you to run it.

**Say:**

I commit to **01.1** or **01.2**, then I always do **03** on that same context so quotas and the whoami app land on the cluster I already built.

**Run:**

_(Open one primary lesson, then **03**.)_

**Expected:**

You are reading either [01 Minikube](01.1-minikube-setup-and-configuration/README.md) or [02 Kind](01.2-kind-kubernetes-in-docker/README.md), followed by [03 Local development clusters](03-local-development-clusters/README.md).

---

## Troubleshooting

- **Started both Minikube and Kind â€œjust to compareâ€** â†’ pick one context with `kubectl config use-context` before **03** or tear down the extra cluster to avoid accidental applies
- **`kubectl: command not found` before 01** â†’ complete the installer steps inside **01.1** or **01.2** first
- **`dev-local` missing after 03** â†’ re-run bootstrap from **03** on the correct context (`minikube` vs `kind-kfsops-kind`)
- **Docker not running (Kind)** â†’ start Docker Desktop or the Linux daemon; Kind cannot create nodes without it
- **Minikube profile confusion** â†’ this course uses profile `kfsops-minikube`; check `minikube profile list`

---

## Learning objective

- Chose **either** Minikube **or** Kind as the single local stack for the module.
- Described why **03** always follows the cluster lesson on the **same** kubectl context.
- Located the three child README paths from `$COURSE_DIR`.

## Why this matters

A stable local cluster plus a governed `dev-local` namespace mirrors how platform teams isolate teams on shared clusters â€” only the scale changes.

## Video close â€” fast validation

**What happens when you run this:**

Read-only checks after **03**: cluster info, namespace, quota objects, pods in `dev-local`. Add `--context kind-kfsops-kind` if you use Kind.

**Say:**

After **03**, I confirm the API answers, `dev-local` exists, and quota objects are bound before I move to Part 1.2.

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
| `01.1-minikube-setup-and-configuration/` | Single-node Minikube track |
| `01.2-kind-kubernetes-in-docker/` | Multi-node Kind track |
| `03-local-development-clusters/` | `dev-local` workspace |

---

## Sections

| Lesson | Link | Choose ifâ€¦ |
|--------|------|------------|
| **01.1** | [Minikube setup](01.1-minikube-setup-and-configuration/README.md) | You want one node, addons (e.g. Ingress), familiar â€œminikube serviceâ€ flow. |
| **01.2** | [Kind](01.2-kind-kubernetes-in-docker/README.md) | You want multi-node-in-Docker, fast spin-up, CI-like workflows. |
| **03** | [Local dev clusters / dev-local](03-local-development-clusters/README.md) | **After** 01.1 or 01.2 â€” quotas, limit ranges, demo app in `dev-local`. |

---

## Next

Open [01](01.1-minikube-setup-and-configuration/README.md) or [02](01.2-kind-kubernetes-in-docker/README.md), then [03](03-local-development-clusters/README.md). Continue with [1.2 Production environment](../02-production-environment/README.md) when your path requires Linux node setup.
