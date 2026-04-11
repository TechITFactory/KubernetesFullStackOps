# Phase 1 — Prerequisites (before Part 1)

## Intro

Complete this phase **before** [Part 1: Getting Started](../part-1-getting-started/README.md). Kubernetes assumes you are comfortable on the Linux command line and understand what containers are and how images run. These two short modules exist so Part 1 is not your first time seeing a shell or a `docker run`.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/part-0-prerequisites"
```

> If you already exported `COURSE_DIR` for a child lesson, skip the export and just `cd`.

## Flow of this lesson

```
  [ 0.1 Linux ]     →     [ 0.2 Docker ]     →     [ Part 1 ]
   terminal skills          images/containers      cluster on your machine
```

**Say:**

We move in one line: Linux shell habits first, then Docker vocabulary, then you are ready to open Part 1. There is no parallel path — 0.1 before 0.2 unless you already have equivalent experience.

---

## Step 1 — Open the prerequisites folder

**What happens when you run this:**

`cd` moves into `part-0-prerequisites`. `pwd` confirms the path.

**Say:**

I stand at the parent of both module folders so the relative links to 0.1 and 0.2 match the repo layout.

**Run:**

```bash
cd "$COURSE_DIR/part-0-prerequisites"
pwd
```

**Expected:**

Path ending with `part-0-prerequisites`.

---

## Step 2 — Complete 0.1 Linux basics

**What happens when you run this:**

You follow [0.1 Linux basics](0.1-linux-basics-for-kubernetes/README.md), run setup, complete the lab steps, and pass `verify-linux-basics.sh`.

**Say:**

0.1 copies files into `~/k8sops-p0-linux-lab` and practices `grep`, `find`, and paths — the same muscle memory as `kubectl` and log diving.

**Run:**

_(Open the [0.1 README](0.1-linux-basics-for-kubernetes/README.md) and run its steps.)_

**Expected:**

`verify-linux-basics: OK` from `0.1-linux-basics-for-kubernetes/scripts/verify-linux-basics.sh`.

---

## Step 3 — Complete 0.2 Docker basics

**What happens when you run this:**

You follow [0.2 Docker basics](0.2-docker-basics-for-kubernetes/README.md) with Docker (or a compatible CLI) running, then pass `verify-docker-basics.sh`.

**Say:**

0.2 ties **image**, **container**, **pull**, **run**, and **ports** to what kubelet and the runtime do later.

**Run:**

_(Open the [0.2 README](0.2-docker-basics-for-kubernetes/README.md) and run its steps.)_

**Expected:**

`verify-docker-basics: OK` from `0.2-docker-basics-for-kubernetes/scripts/verify-docker-basics.sh`.

---

## Troubleshooting

- **`cd: part-0-prerequisites: No such file or directory`** → set `COURSE_DIR` to your actual clone root (for example `$HOME/K8sOps`)
- **`verify-linux-basics` fails on ERROR count** → edit `~/k8sops-p0-linux-lab/servers.log` so at least one line contains space-padded ` ERROR `; see the 0.1 lesson
- **`Cannot connect to the Docker daemon` in 0.2** → start Docker Desktop or `docker.service` before the verify script
- **Skipping 0.1 or 0.2** → Part 1 assumes terminal + container fluency; expect friction on Minikube, Kind, and logs
- **Running verifies from the wrong directory** → run Linux verify from `0.1-linux-basics-for-kubernetes` after setup; Docker verify from `0.2-docker-basics-for-kubernetes`

---

## Learning objective

- Located `part-0-prerequisites` under `$COURSE_DIR` and completed 0.1 then 0.2 in order.
- Passed both `verify-linux-basics.sh` and `verify-docker-basics.sh` on a machine that matches the lesson assumptions.

## Why this matters

All labs in this course use Linux-style commands ([`COURSE_MASTER_PLAN.md`](../COURSE_MASTER_PLAN.md)). Kubernetes runs containers; without runtime basics, node and workload debugging stays opaque.

## Video close — fast validation

**What happens when you run this:**

From the **repository root**, quick OS probe plus conditional verify script paths using `$COURSE_DIR`. The Docker line uses `|| true` so a missing daemon does not abort the whole block.

**Say:**

I prove the kernel identity, run the Linux verify when the script path exists from the root, then try the Docker verify or print a reminder — all read-only except the verify scripts themselves which only check state.

**Run:**

```bash
cd "$COURSE_DIR"
uname -a
test -x "$COURSE_DIR/part-0-prerequisites/0.1-linux-basics-for-kubernetes/scripts/verify-linux-basics.sh" && \
  (cd "$COURSE_DIR/part-0-prerequisites/0.1-linux-basics-for-kubernetes" && ./scripts/verify-linux-basics.sh)
command -v docker >/dev/null && (cd "$COURSE_DIR/part-0-prerequisites/0.2-docker-basics-for-kubernetes" && ./scripts/verify-docker-basics.sh) || echo "Complete 0.2 when Docker is installed"
```

**Expected:**

`uname` output; Linux verify OK after 0.1 setup; Docker verify OK or the echo line.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `0.1-linux-basics-for-kubernetes/` | Shell lab + `verify-linux-basics.sh` |
| `0.2-docker-basics-for-kubernetes/` | Container lab + `verify-docker-basics.sh` |

---

## Modules

Each lesson is a **teaching transcript**: numbered steps with **What happens when you run this**, **Say**, **Run**, and **Expected**.

| Module | README | Assets |
|--------|--------|--------|
| **0.1** | [Linux basics](0.1-linux-basics-for-kubernetes/README.md) | `lab-files/`, `scripts/`, `yamls/failure-troubleshooting.yaml` |
| **0.2** | [Docker basics](0.2-docker-basics-for-kubernetes/README.md) | `docker/Dockerfile`, `scripts/verify-docker-basics.sh`, `yamls/failure-troubleshooting.yaml` |

Each module includes `scripts/` for setup and verify, and optional `yamls/failure-troubleshooting.yaml` for in-cluster cheat sheets.

---

## Next

Continue to [Part 1: Getting Started](../part-1-getting-started/README.md).
