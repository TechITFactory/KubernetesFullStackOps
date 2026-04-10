# Phase 1 — Prerequisites (before Part 1)

Complete this phase **before** [Part 1: Getting Started](../part-1-getting-started/README.md). Kubernetes assumes you are comfortable on the Linux command line and understand what containers are and how images run.

## Teaching vs self-study (how README + transcript work)

- **Teach-as-you-go script** (inside **0.1** and **0.2**): **You say** → **You run** → **You should see** in one linear flow — closest to “I am teaching you live with talk and commands.” Start there if you want one document to read from while typing.
- **Lab / Quick Start**: same commands, **commands-only** layout for copy-paste and search.
- **Transcript** at the bottom of each module: **short spoken recap** of the same story (good for timing labels on a video, not a full second lab).

## Modules (same lesson shape as Kubernetes parts)

| Module | README | What you ship |
|--------|--------|----------------|
| **0.1** | [Linux basics for Kubernetes](0.1-linux-basics-for-kubernetes/README.md) | Metadata, lab steps, Quick Start, Expected output, Video close, troubleshooting, assessment, transcript |
| **0.2** | [Docker basics for Kubernetes](0.2-docker-basics-for-kubernetes/README.md) | Same structure + `docker build` / `docker run` / port lab + `verify-docker-basics.sh` |

Each module includes:

- `scripts/` — runnable setup and verify scripts (like Part 1 labs)
- `yamls/failure-troubleshooting.yaml` — ConfigMap asset matching Kubernetes lessons (optional `kubectl apply` if you want it in-cluster)

## Why this is Phase 1

- All labs in this course use **Linux-only** commands ([`COURSE_MASTER_PLAN.md`](../COURSE_MASTER_PLAN.md)).
- Kubernetes runs **containers**; without runtime basics, node and workload debugging stays opaque.
- Skipping this phase usually shows up as wasted time in Part 1 (Minikube/kind, `kubectl`, logs).

## Completion check

You are ready for Part 1 when:

- `./scripts/verify-linux-basics.sh` exits `0` from `0.1-linux-basics-for-kubernetes` (after setup).
- `./scripts/verify-docker-basics.sh` exits `0` from `0.2-docker-basics-for-kubernetes`.

## Part wrap — quick validation

```bash
uname -a
test -x part-0-prerequisites/0.1-linux-basics-for-kubernetes/scripts/verify-linux-basics.sh && \
  (cd part-0-prerequisites/0.1-linux-basics-for-kubernetes && ./scripts/verify-linux-basics.sh)
command -v docker >/dev/null && part-0-prerequisites/0.2-docker-basics-for-kubernetes/scripts/verify-docker-basics.sh || echo "Complete 0.2 when Docker is installed"
```

From the **repository root**, adjust paths if your clone layout differs; from each module directory, run `./scripts/verify-*.sh` directly.

Green lights: Linux verify OK; Docker verify OK once the daemon is running.
