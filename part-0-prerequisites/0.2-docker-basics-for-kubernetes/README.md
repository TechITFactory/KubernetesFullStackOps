# 0.2 Docker Basics for Kubernetes

- **Summary**: Images, containers, registries, builds, and port publishing — the vocabulary and commands Kubernetes reuses when it runs workloads.
- **Content**: Aligns with Track 0 in [`COURSE_MASTER_PLAN.md`](../../COURSE_MASTER_PLAN.md). Supply-chain hardening comes later in the full course.
- **Lab**: Use Docker Engine (Linux) or **Docker Desktop** / **Rancher Desktop**; **Podman** works if `docker` is a compatible alias or symlink.

**Want it like a real class?** Use **[Teach-as-you-go script](#teach-as-you-go-script-say-this-then-run-this)** — talk and commands together. Below that, the same lesson appears as Lab / Quick Start / Transcript for reference.

## If you have zero prior experience

- Complete **[0.1 Linux basics](../0.1-linux-basics-for-kubernetes/README.md)** first (terminal + files + `grep`).
- This lesson assumes **Docker is installed** and `docker info` works. If not, install **Docker Desktop** (Windows/Mac) or Docker Engine (Linux) using the official docs, then return.
- **Pace**: Finish **Lab Step 1–3** before the nginx **port** exercise (Step 4) if builds or pulls are slow.

## Teach-as-you-go script (say this, then run this)

Read **You say**, then paste **You run**. Replace `/path/to/K8sOps` with your clone path. Docker must be running (`docker info` works).

---

**You say:** “Kubernetes runs **containers** from **images**. Docker on your laptop is the same vocabulary: pull an image, run a container, read logs, publish a port.”

**You run:** (nothing yet)

---

**You say:** “First I prove the Docker **client** can talk to the **daemon**. If this fails, I fix Docker Desktop or `docker.service` before anything else.”

**You run:**

```bash
docker version
docker info
```

**You should see:** Client and Server sections; no “Cannot connect to the Docker daemon”.

---

**You say:** “`docker pull` downloads an image from a **registry**. `docker run` starts a **container**. `--rm` deletes the container when it exits — good for demos.”

**You run:**

```bash
docker pull hello-world
docker run --rm hello-world
```

**You should see:** The hello-world banner text.

---

**You say:** “A **Dockerfile** is a recipe. `docker build` bakes an **image** with a tag. `docker run` starts a container from that image — same pattern as Kubernetes pulling an image for a Pod.”

**You run:**

```bash
cd /path/to/K8sOps/part-0-prerequisites/0.2-docker-basics-for-kubernetes
chmod +x scripts/*.sh
docker build -t k8sops-p0-lab:0.2 docker/
docker run --rm k8sops-p0-lab:0.2
```

**You should see:** Build steps complete; one line like `K8sOps Part 0 Docker lab`.

---

**You say:** “`-p 8080:80` maps **host port 8080** to **container port 80**. Traffic hits my laptop first, then nginx inside the container. I will stop and remove the container when done.”

**You run:**

```bash
docker run -d --name k8sops-p0-web -p 8080:80 nginx:1.27-alpine
docker ps --filter name=k8sops-p0-web
docker logs k8sops-p0-web 2>&1 | tail -n 5
curl -sS -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8080/
docker stop k8sops-p0-web
docker rm k8sops-p0-web 2>/dev/null || true
```

**You should see:** Container `Up` in `docker ps`; curl prints `200` (or another success code).

---

**You say:** “The course ships a script that repeats pull, build, and run so I can regression-check my machine anytime.”

**You run:**

```bash
cd /path/to/K8sOps/part-0-prerequisites/0.2-docker-basics-for-kubernetes
./scripts/verify-docker-basics.sh
```

**You should see:** `verify-docker-basics: OK (image k8sops-p0-lab:0.2 built and ran)`.

---

**You say:** “If the daemon is down, pulls time out, or the port is busy — that is normal local friction. Fix the runtime, retry, or change the left side of `-p`. Next is Part 1: we swap Docker run for `kubectl run` and Deployments.”

---

## How commands and transcript fit together (not two different lessons)

The **Teach-as-you-go script** above is the **merged** lesson (talk + commands). Below, the **Lab** / **Quick Start** / **Transcript** repeat the same story in reference form.

| Mode | What you do |
|------|----------------|
| **Self-study** | Prefer **Teach-as-you-go** once, then skim **Concepts** and keep **Quick Start** as a cheat sheet. |
| **Teaching / recording** | Prefer **Teach-as-you-go** top to bottom; or **Lab** blocks + **Transcript** mapping. |
| **Fast review** | **Quick Start** + **Video close** only. |

**Transcript ↔ lab mapping (0.2)**

| Transcript | Follow on screen / keyboard |
|------------|-----------------------------|
| `[0:00-0:30]` Hook | **Summary** + **Learning Objective**. |
| `[0:30-2:00]` Concept | **Concepts (Short Theory)** (image vs container). |
| `[2:00-7:00]` Hands-on | **Lab Steps 1–5** (`docker info` → hello-world → build → nginx port → verify script). |
| `[7:00-9:00]` Troubleshooting | **Troubleshooting (Top 5)** + `yamls/failure-troubleshooting.yaml`. |
| `[9:00-10:00]` Recap | **Summary**, **Next Lesson**, **Video close**. |

**What is *not* inside this README**

| Location | What lives there |
|----------|------------------|
| `docker/Dockerfile` | Image recipe used in **Lab Step 3**. |
| `scripts/verify-docker-basics.sh` | End-to-end check (pull + build + run). |
| `yamls/failure-troubleshooting.yaml` | Optional ConfigMap-style cheat sheet (same pattern as K8s lessons). |

## Metadata

- Duration: `90–120` minutes (first pass)
- Difficulty: `Beginner`
- Practical/Theory: `70/30`
- Tested on Kubernetes: `N/A` (container runtime on host)
- Also valid for: `Docker Desktop, rootless Docker, Podman (docker-compatible CLI)`
- Lab OS: `Linux` or `macOS` or `Windows + WSL2/Docker Desktop`
- Platform: `Local container runtime`

## Learning Objective

By the end of this lesson, you will be able to:

- Explain the difference between an **image** (read-only template) and a **container** (running instance).
- Pull from a registry, run interactively and detached, and clean up with `stop` / `rm`.
- Read **logs** and run an interactive **exec** shell where the image allows it.
- Publish a host port to a container port (`-p host:container`) and verify with `curl`.
- Build a small image from a **Dockerfile** and tag it locally.

## Why This Matters in Real Jobs

Kubernetes schedules **containers** created from **images**. When an image fails to pull, a port is wrong, or an entrypoint crashes, you debug with the same mental model as `docker run` and `docker logs` — just at higher scale and with controllers in front. Interviewers often ask “what happens when you run a container?” before they ask about Pods.

## Prerequisites

- [0.1 Linux basics for Kubernetes](../0.1-linux-basics-for-kubernetes/README.md)
- Docker daemon running (`docker info` succeeds).

## Concepts (Short Theory)

- **Image**: Layers + metadata; identified by name and tag (`nginx:1.27`) or digest.
- **Container**: Writable thin layer on top of an image; gets an ID and optional name.
- **Registry**: Stores images (e.g. Docker Hub); `pull` copies locally, `push` publishes (not required in this lab).
- **Dockerfile**: Recipe to build an image (`FROM`, `COPY`, `RUN`, `CMD`) — Kubernetes does not run the Dockerfile; it runs the **built** image.

## Files

| Path | Purpose |
|------|---------|
| `docker/Dockerfile` | Tiny image for `docker build` practice |
| `scripts/verify-docker-basics.sh` | Pull `hello-world`, build tag `k8sops-p0-lab:0.2`, run both |
| `yamls/failure-troubleshooting.yaml` | ConfigMap-style cheat sheet (same asset pattern as K8s lessons) |

## Lab: Step-by-Step Practical

### Step 1 — Runtime check

```bash
docker version
docker info
```

**Success signal**: client and server versions print. **Failure signal**: “Cannot connect to the Docker daemon” → start Docker / service.

### Step 2 — Pull and run (ephemeral container)

```bash
docker pull hello-world
docker run --rm hello-world
```

`--rm` deletes the container when it exits — good hygiene for one-shot demos.

### Step 3 — Build and run your image

```bash
cd /path/to/K8sOps/part-0-prerequisites/0.2-docker-basics-for-kubernetes
chmod +x scripts/*.sh
docker build -t k8sops-p0-lab:0.2 docker/
docker run --rm k8sops-p0-lab:0.2
```

You should see the lab message printed from the image `CMD`.

### Step 4 — Detached run, logs, port, cleanup

```bash
docker run -d --name k8sops-p0-web -p 8080:80 nginx:1.27-alpine
docker ps --filter name=k8sops-p0-web
docker logs k8sops-p0-web 2>&1 | tail -n 5
curl -sS -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8080/
docker stop k8sops-p0-web
docker rm k8sops-p0-web 2>/dev/null || true
```

### Step 5 — Automated verify

```bash
./scripts/verify-docker-basics.sh
```

## Quick Start

```bash
chmod +x scripts/*.sh
./scripts/verify-docker-basics.sh
```

## Expected output

- `docker run --rm hello-world` prints the hello-world banner.
- `docker build` completes and `docker run --rm k8sops-p0-lab:0.2` prints a one-line lab message.
- `verify-docker-basics.sh` ends with `verify-docker-basics: OK`.

## Video close — fast validation

```bash
docker ps
docker images | head -n 5
./scripts/verify-docker-basics.sh
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` — daemon socket, auth, ports, and disk (same ConfigMap pattern as Kubernetes lessons). Optional: apply into a cluster if you want the hints next to other lesson maps.

## Troubleshooting (Top 5)

1. **Cannot connect to Docker daemon** → Start Docker Desktop or `sudo systemctl start docker` (Linux).
2. **Permission denied on socket** → Add user to `docker` group and re-login, or use rootless Docker.
3. **`port is already allocated`** → Change `-p 8081:80` or stop the container using `8080`.
4. **`pull` timeout** → Check VPN/firewall; retry; try another registry mirror if your org requires it.
5. **Build fails on `FROM alpine`** → Network to registry; corporate proxy may need `HTTP_PROXY` build args (advanced — note for work laptops).

## Hands-On Challenge

- Change `docker/Dockerfile` to add `ENV LAB_USER=yourname`, rebuild, and `docker run --rm` with `docker run --rm k8sops-p0-lab:0.2 env | grep LAB`.

## Assessment

- Quiz: In one sentence, what is the difference between an image and a container?
- Quiz: What does `-p 8080:80` mean for traffic direction?
- Practical check: `./scripts/verify-docker-basics.sh` exits `0`.

## Version and Compatibility Notes

- **Docker API**: Course scripts use stable CLI flags; very old Docker may differ slightly on `docker build` output.
- **Podman**: Often `alias docker=podman`; rootless mode may affect published ports on some setups.
- **Apple Silicon**: Use images that publish `arm64` variants (e.g. `alpine`, official `nginx` multi-arch).

## Summary

- **Pattern**: `pull` → `run` → `logs` / `exec` → `stop` / `rm`; `build` when you own the image recipe.
- **Rule**: Name long-running containers (`--name`) so you can clean them up deliberately.
- **Habit**: Prefer `--rm` for throwaway runs; use explicit tags, not bare `latest`, when you care about repeatability.

## Next Lesson

[Part 1: Getting Started](../../part-1-getting-started/README.md) — local clusters and `kubectl` assume this container vocabulary.

## Transcript (Simple Spoken English)

**What this section is for:** A **short, timed outline** for a ~10 minute voiceover (chapter markers / quick recap). It is **not** the full teaching script and **not** a command list — use **Teach-as-you-go** or **Lab** for talk + commands together.

`[0:00-0:30]`  
Kubernetes does not run Dockerfiles. It runs **containers** built from **images**. If you can pull, run, and read logs with Docker locally, the first week of Kubernetes clicks faster.

`[0:30-2:00]`  
An **image** is a packaged filesystem and startup command. A **container** is that image running once, with its own process ID and writable layer. When a pod “restarts,” think: old container gone, new container from the same image.

`[2:00-7:00]`  
Run `verify-docker-basics.sh` after `docker info` works. It pulls `hello-world`, which proves registry reachability. Then it builds our tiny Alpine-based lab image and runs it. After that, run nginx with `-p 8080:80` and hit it with `curl`. That is the same host-to-container port idea as a NodePort or Ingress later — just smaller.

`[7:00-9:00]`  
If you see “cannot connect to daemon,” that is not a Kubernetes problem yet — fix the runtime first. If pull fails, it is often network or auth. If the port is busy, change the left side of `-p`.

`[9:00-10:00]`  
Clean up named containers so your machine is not littered. When verify prints OK, you are ready for Part 1: you have shell skills from 0.1 and container skills from 0.2 — the two foundations under every `kubectl` lab.
