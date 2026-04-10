# 0.2 Docker Basics for Kubernetes — teaching transcript

## Intro

Alright — in this lesson, we’re not becoming Docker experts.

We’re learning the **same words Kubernetes uses**:

- **Image** — the packaged app (layers + metadata)
- **Container** — one running instance of an image
- **Pull / run / logs / ports** — what you’ll debug on a cluster later, just smaller here

That’s the thread.

**Before this:** finish [0.1 Linux basics](../0.1-linux-basics-for-kubernetes/README.md) (terminal + `cd` + paste commands).

**You need:** Docker installed and running — `docker info` should work with no “cannot connect to daemon” error. (Docker Desktop on Windows/Mac, or Docker Engine on Linux. Podman with a `docker`-compatible CLI is fine.)

Replace **`/path/to/K8sOps`** in the steps below with the folder where you cloned this repo.

If pulls or builds are slow — do **Steps 1–4**, take a break, then do **5–6**.

---

## Step 1 — Move into the lesson folder

**Say:**  
I work from this lesson directory so `docker/` and `scripts/` paths are correct.

**Run:**

```bash
cd /path/to/K8sOps/part-0-prerequisites/0.2-docker-basics-for-kubernetes
pwd
```

**Expected:**  
Path ending with `0.2-docker-basics-for-kubernetes`.

---

## Step 2 — Prove the Docker client talks to the daemon

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

**Say:**  
A **Dockerfile** is a recipe. `docker build` creates a **tagged image** on my machine. `docker run` starts a container from that image — same idea as a Pod that uses `image: ...` in YAML.

**Run:**

```bash
cd /path/to/K8sOps/part-0-prerequisites/0.2-docker-basics-for-kubernetes
chmod +x scripts/*.sh
docker build -t k8sops-p0-lab:0.2 docker/
docker run --rm k8sops-p0-lab:0.2
```

**Expected:**  
Build completes; container prints something like `K8sOps Part 0 Docker lab`.

---

## Step 5 — Run a server in the background, hit a port, clean up

**Say:**  
`-p 8080:80` means: traffic to **my machine’s port 8080** goes to **port 80 inside the container**. That’s the same *idea* as publishing a service later — just on my laptop. I use a **name** so I can stop and remove the container cleanly.

**Run:**

```bash
docker run -d --name k8sops-p0-web -p 8080:80 nginx:1.27-alpine
docker ps --filter name=k8sops-p0-web
docker logs k8sops-p0-web 2>&1 | tail -n 5
curl -sS -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8080/
docker stop k8sops-p0-web
docker rm k8sops-p0-web 2>/dev/null || true
```

**Expected:**  
Container shows as running in `docker ps`; `curl` prints `200` (or another success HTTP code); stop/rm completes without a name conflict next time.

---

## Step 6 — Run the course verify script

**Say:**  
This script repeats pull, build, and run so I can regression-check my machine anytime.

**Run:**

```bash
cd /path/to/K8sOps/part-0-prerequisites/0.2-docker-basics-for-kubernetes
./scripts/verify-docker-basics.sh
```

**Expected:**  
`verify-docker-basics: OK`.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `docker/Dockerfile` | Image recipe used in Step 4 |
| `scripts/verify-docker-basics.sh` | Step 6 — full check |
| `yamls/failure-troubleshooting.yaml` | Optional cheat sheet (same idea as K8s lesson YAMLs) |

---

## Troubleshooting

- Cannot connect to daemon → start Docker Desktop or `sudo systemctl start docker` (Linux)
- Permission denied on socket → add user to `docker` group and re-login, or rootless Docker per your distro
- Port already in use → use `-p 8081:80` or `docker stop` the old container using `8080`
- Pull timeout / build fails on `FROM` → network, VPN, corporate proxy, or registry mirror
- Leftover `k8sops-p0-web` → `docker rm -f k8sops-p0-web` then retry Step 5

---

## Learning objective

- Explain **image** vs **container**
- `pull`, `run` (with and without `--rm`), `build`, `-p`, `logs`, `stop`, `rm`
- Run `./scripts/verify-docker-basics.sh` successfully

---

## Why this matters

On a cluster, workloads are **containers from images**. When something breaks, you’ll think in terms of pull errors, crash loops, ports, and logs — same vocabulary as this lesson, just with `kubectl` in front later.

---

## Challenge

Add a line to `docker/Dockerfile` after the existing `RUN` (still as root), for example:

```dockerfile
ENV LAB_USER=yourname
```

Rebuild and prove the variable is visible:

**Run:**

```bash
cd /path/to/K8sOps/part-0-prerequisites/0.2-docker-basics-for-kubernetes
docker build -t k8sops-p0-lab:0.2 docker/
docker run --rm k8sops-p0-lab:0.2 env | grep LAB_USER
```

**Expected:**  
`LAB_USER=yourname` (or whatever you set).

---

## Next

[Part 1: Getting Started](../../part-1-getting-started/README.md)
