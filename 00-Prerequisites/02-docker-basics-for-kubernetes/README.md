# 0.2 Docker Basics for Kubernetes — teaching transcript

## Intro

Alright — in this lesson, we’re not becoming Docker experts.

We’re learning the **same words Kubernetes uses**:

- **Image** — the packaged app (layers + metadata)
- **Container** — one running instance of an image
- **Pull / run / logs / ports** — what you’ll debug on a cluster later, just smaller here

That’s the thread.

**Before this:** finish [0.1 Linux basics](../01-linux-basics-for-kubernetes/README.md) (terminal + `cd` + paste commands).

**You need:** Docker installed and running — `docker info` should work with no “cannot connect to daemon” error. (Docker Desktop on Windows/Mac, or Docker Engine on Linux. Podman with a `docker`-compatible CLI is fine.)

If pulls or builds are slow — do **Steps 1–4**, take a break, then do **5–6**.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/00-Prerequisites/02-docker-basics-for-kubernetes"
```

> If you set `COURSE_DIR` in lesson 0.1, it is still set in your current shell — skip the export and just `cd`.

## Flow of this lesson

```
  [ Registry ]          [ Image ]           [ Container ]       [ Operate ]
               ──pull──▶  local   ──run──▶   running      ──▶  logs / stop / rm
                                                                verify script
```

**Say:**

We pull an image from a registry, run it as a container, then operate on a longer-running container with ports and logs. We finish with the course verify script so the whole path is repeatable.

---

## Step 1 — Move into the lesson folder

**What happens when you run this:**

`cd` moves into the lesson folder; `pwd` prints the path — no Docker state changes.

**Say:**

I work from this lesson directory so `docker/` and `scripts/` paths are correct.

**Run:**

```bash
cd "$COURSE_DIR/00-Prerequisites/02-docker-basics-for-kubernetes"
pwd
```

**Expected:**

Path ending with `02-docker-basics-for-kubernetes`.

---

## Step 2 — Prove the Docker client talks to the daemon

**What happens when you run this:**

`docker version` asks the CLI and daemon for version strings (proves both sides exist). `docker info` dumps daemon configuration and confirms the socket/API is reachable — still no containers created yet.

**Say:**

If this step fails, nothing else will work — I fix Docker Desktop or `docker.service` first, not Kubernetes.

**Run:**

```bash
docker version
docker info
```

**Expected:**

Client and Server sections; **no** “Cannot connect to the Docker daemon”.

---

## Step 3 — Pull an image and run a one-shot container

**What happens when you run this:**

`docker pull hello-world` downloads image layers to local storage. `docker run --rm hello-world` creates a container from that image, runs its entrypoint (prints the hello message), then **removes** the container on exit — the image stays cached locally.

**Say:**

`docker pull` copies an image from a **registry** (here, Docker Hub). `docker run` starts a **container**. `--rm` deletes the container when it exits — good for demos.

**Run:**

```bash
docker pull hello-world
docker run --rm hello-world
```

**Expected:**

“Hello from Docker!” (or similar) success message.

---

## Step 4 — Build a small image and run it

**What happens when you run this:**

`chmod +x scripts/*.sh` makes helper scripts executable. `docker build -t k8sops-p0-lab:0.2 docker/` reads `docker/Dockerfile`, runs its instructions, and tags the result as `k8sops-p0-lab:0.2` locally. `docker run --rm k8sops-p0-lab:0.2` runs one container from that tag and removes it when it exits.

**Say:**

A **Dockerfile** is a recipe. `docker build` creates a **tagged image** on my machine. `docker run` starts a container from that image — same idea as a Pod that uses `image: ...` in YAML.

**Run:**

```bash
chmod +x scripts/*.sh
docker build -t k8sops-p0-lab:0.2 docker/
docker run --rm k8sops-p0-lab:0.2
```

> **Note:** No need to `cd` again — still in lesson folder from Step 1.

**Expected:**

Build completes; container prints something like `K8sOps Part 0 Docker lab`.

---

## Step 5 — Run a server in the background, hit a port, clean up

**What happens when you run this:**

`docker run -d ...` starts nginx detached. `docker ps`, `docker logs`, and `curl` check the container. `docker stop` stops it; `docker rm` removes it. `2>/dev/null` hides “no such container” text on re-runs; `|| true` keeps the line from failing if remove was already done.

**Say:**

`-p 8080:80` maps my machine’s port 8080 to port 80 inside the container — same *idea* as publishing a service later. I use a fixed name so stop and remove are predictable. On `docker rm`, I hide stderr and allow a non-zero exit so repeating the lesson does not error out.

**Run:**

```bash
docker run -d --name k8sops-p0-web -p 8080:80 nginx:1.27-alpine
docker ps --filter name=k8sops-p0-web
docker logs k8sops-p0-web 2>&1 | tail -n 5
curl -sS -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8080/
docker stop k8sops-p0-web
docker rm k8sops-p0-web 2>/dev/null || true
```

> **WSL2 with Docker Desktop:** if `curl` to `127.0.0.1` fails while the container is running, try `HOST=$(hostname -I | awk '{print $1}')` then `curl -sS -o /dev/null -w "%{http_code}\n" "http://${HOST}:8080/"`. Some setups route published ports on the VM IP rather than loopback.

**Expected:**

Container shows as running in `docker ps`; `curl` prints `200`; stop completes; `rm` does not abort the script on a second run.

---

## Step 6 — Run the course verify script

**What happens when you run this:**

`./scripts/verify-docker-basics.sh` checks `docker info`, then pull/run `hello-world`, then build `docker/Dockerfile` and run that image — end-to-end smoke test; leaves the built image tagged on your machine.

**Say:**

This script repeats pull, build, and run so I can regression-check my machine anytime. I stay in the lesson folder from Step 1 — no extra `cd`.

**Run:**

```bash
./scripts/verify-docker-basics.sh
```

**Expected:**

`verify-docker-basics: OK`.

---

## Troubleshooting

- **`Cannot connect to the Docker daemon`** → start Docker Desktop or `sudo systemctl start docker` (Linux)
- **`permission denied while trying to connect to the Docker daemon socket`** → add your user to the `docker` group and re-login, or use rootless Docker per your distro
- **`bind: address already in use`** on port 8080 → use `-p 8081:80` and curl that port, or `docker rm -f k8sops-p0-web` then retry
- **`curl: (7) Failed to connect`** on WSL2 while `docker ps` shows the container → use `$(hostname -I | awk '{print $1}')` as the host in the URL instead of `127.0.0.1`
- **Image pull or build fails on `FROM`** → check network, VPN, corporate proxy, or registry mirror settings

---

## Learning objective

- Stated the difference between an **image** and a **container**.
- Ran `pull`, `run` (with and without `--rm`), `build`, port publish, `logs`, `stop`, and `rm`.
- Ran `./scripts/verify-docker-basics.sh` successfully end to end.

## Why this matters

On a cluster, workloads are **containers from images**. When something breaks, you’ll think in terms of pull errors, crash loops, ports, and logs — the same vocabulary as this lesson, later with `kubectl` in front.

## Video close — fast validation

**What happens when you run this:**

Read-only checks: client talks to daemon and hello-world image is present (pull is skipped if already local — harmless).

**Say:**

I confirm the daemon answers and the tutorial image is cached before signing off.

**Run:**

```bash
docker version --format '{{.Client.Version}}' 2>/dev/null || docker version
docker image inspect hello-world >/dev/null 2>&1 && echo "hello-world image: OK" || true
```

**Expected:**

A client version line (or full `docker version`); `hello-world image: OK` if the image exists.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `docker/Dockerfile` | Image recipe used in Step 4 |
| `scripts/verify-docker-basics.sh` | Step 6 — full check |
| `yamls/failure-troubleshooting.yaml` | Optional cheat sheet (same idea as K8s lesson YAMLs) |

---

## Challenge

**What happens when you run this:**

You compare a **wrong** Dockerfile that sets `ENV` after `USER` (so the variable is easy to misuse) with a **correct** one that sets `ENV` before switching to the non-root user. Then you rebuild and show the variable inside the container.

**Say:**

The wrong file puts `ENV` after `USER appuser`. The right file sets `ENV LAB_USER` before `USER appuser` so the image metadata is clear and tools see the variable the same way in both root and user layers during build. I rebuild, run `env`, and grep for `LAB_USER`.

**Run:**

Wrong Dockerfile (do not ship this — `ENV` after `USER`):

```dockerfile
FROM alpine:3.19
RUN adduser -D -u 1000 appuser && \
    echo "K8sOps Part 0 Docker lab" > /etc/lab-message.txt
USER appuser
WORKDIR /home/appuser
ENV LAB_USER=yourname
CMD ["cat", "/etc/lab-message.txt"]
```

Correct Dockerfile (replace `docker/Dockerfile` with this shape):

```dockerfile
FROM alpine:3.19
RUN adduser -D -u 1000 appuser && \
    echo "K8sOps Part 0 Docker lab" > /etc/lab-message.txt
ENV LAB_USER=yourname
USER appuser
WORKDIR /home/appuser
CMD ["cat", "/etc/lab-message.txt"]
```

Then rebuild and prove the variable is visible:

```bash
docker build -t k8sops-p0-lab:0.2 docker/
docker run --rm k8sops-p0-lab:0.2 env | grep LAB_USER
```

> **Note:** No need to `cd` again — still in lesson folder from Step 1.

**Expected:**

`LAB_USER=yourname` (or whatever value you set).

---

## Next

[Part 1: Getting Started](../../01-Local-First-Operations/README.md)
