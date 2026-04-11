# 1.2.1.3 Docker Engine (via cri-dockerd) — teaching transcript

## Intro

**Kubernetes 1.24+** removed **dockershim**. **Docker Engine** is not a native kubelet runtime anymore. **cri-dockerd** is a **CRI shim**: kubelet → cri-dockerd → Docker → containers.

Use this path for **legacy or migration** only — **not** for new clusters (**containerd** or **CRI-O** is simpler).

**You need:** **Linux node**, **`sudo`**.

**Pick one runtime:** if you standardize on **containerd** or **CRI-O**, skip this lesson — see [1.2.1](../README.md).

**Teaching tip:** Each step includes **What happens when you run this** before **Run**. `scripts/install-docker-cri-dockerd.sh` repeats the install story in a header comment at the top of the file.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/part-1-getting-started/1.2-production-environment/1.2.1-container-runtimes/1.2.1.3-docker-engine-via-cri-dockerd"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  chmod scripts  →  sudo install      →  both systemd   →  cri-dockerd   →  crictl info  →  cgroup grep  →  kubeadm YAML
                    Docker + shim         units active       socket          shim            docker info      grep
```

**Say:**

This path installs Docker plus the cri-dockerd shim, proves both services, proves the **CRI** socket (not `docker.sock`), runs `crictl` through the shim, checks Docker’s cgroup driver, then shows the kubeadm `criSocket` line.

---

## Step 1 — Open this lesson in the terminal

**What happens when you run this:**  
`cd`, `pwd`, `chmod +x scripts/*.sh` — lesson folder + executable scripts only.

**Say:**  
I move into the lesson folder and make scripts executable before installing anything.

**Run:**

```bash
cd "$COURSE_DIR/part-1-getting-started/1.2-production-environment/1.2.1-container-runtimes/1.2.1.3-docker-engine-via-cri-dockerd"
pwd
chmod +x scripts/*.sh
```

**Expected:**  
Path ends with `1.2.1.3-docker-engine-via-cri-dockerd`.

---

## Step 2 — Install Docker + cri-dockerd (root, idempotent)

**What happens when you run this:**  
`sudo ./scripts/install-docker-cri-dockerd.sh` apt-installs `docker.io` and `cri-dockerd`, enables/restarts Docker and cri-docker — see script header.

**Say:**  
Script installs packages and enables **docker** and **cri-docker** (socket + service). Idempotent package checks.

**Run:**

```bash
sudo ./scripts/install-docker-cri-dockerd.sh
```

**Expected:**  
Completes without error.

---

## Step 3 — Both services are up

**What happens when you run this:**  
`systemctl is-active` / `status` for Docker and cri-docker units — verifies both daemons are running.

**Say:**

Kubelet needs **both** Docker and the cri-dockerd service healthy — if either is down, pod sandboxes never start.

**Run:**

```bash
sudo systemctl is-active docker
sudo systemctl is-active cri-docker
sudo systemctl status docker --no-pager
sudo systemctl status cri-docker --no-pager
```

**Expected:**  
Both `active` (unit names may be `cri-docker` / `cri-docker.socket` depending on distro — follow `systemctl list-units | grep -i cri` if unsure).

---

## Step 4 — CRI socket (not Docker’s socket)

**What happens when you run this:**  
`ls -la /run/cri-dockerd.sock` confirms the **CRI** shim socket exists (distinct from Docker’s API socket).

**Say:**  
kubeadm must use **cri-dockerd’s** CRI socket — **not** `/var/run/docker.sock`.

**Run:**

```bash
ls -la /run/cri-dockerd.sock
```

**Expected:**  
Socket exists.

---

## Step 5 — CRI responds through cri-dockerd

**What happens when you run this:**  
`crictl ... info` talks to cri-dockerd’s endpoint and returns JSON — proves kubelet could use the same socket.

**Run:**

```bash
sudo crictl --runtime-endpoint unix:///run/cri-dockerd.sock info
```

**Expected:**  
JSON; no connection error.

---

## Step 6 — Cgroup driver check (Docker)

**What happens when you run this:**  
`docker info | grep -i cgroup` prints Docker’s cgroup driver line — read-only; you may need to change `daemon.json` and restart Docker if it shows **cgroupfs**.

**Say:**  
On older distros Docker may still use **cgroupfs**. kubelet should use **systemd** — they must match. Newer Ubuntu often defaults correctly.

**Run:**

```bash
docker info 2>/dev/null | grep -i cgroup
```

**Expected:**  
Ideally `systemd`. If you see **cgroupfs**, configure `/etc/docker/daemon.json` with `native.cgroupdriver=systemd`, restart Docker, **before** kubeadm (see your distro docs).

---

## Step 7 — Match kubeadm to cri-dockerd socket

**What happens when you run this:**  
`grep` on the example kubeadm node config shows the expected `criSocket` for cri-dockerd — no apply.

**Run:**

```bash
grep -n criSocket yamls/kubeadm-node-config-cri-dockerd.yaml
```

**Expected:**  
`unix:///run/cri-dockerd.sock` (or equivalent).

---

## Step 8 — Fast recap

**What happens when you run this:**  
`systemctl status` for both services and `crictl version` through the shim — final verification pass.

**Say:**

Last check: both daemons still up, `crictl` still answers on the shim socket — that is the path kubelet must use.

**Run:**

```bash
sudo systemctl status docker cri-docker --no-pager
sudo crictl --runtime-endpoint unix:///run/cri-dockerd.sock version
```

**Expected:**  
Services OK; `crictl` works.

---

## Troubleshooting

- **`kubeadm` config still references `/var/run/docker.sock`** → replace with `unix:///run/cri-dockerd.sock` — kubelet talks CRI, not the Docker API
- **`cri-docker.service` inactive (dead)`** → enable and start `cri-docker.socket` / `cri-docker.service` per your distro packages
- **`Cgroup Driver: cgroupfs` in `docker info`** → set `"exec-opts": ["native.cgroupdriver=systemd"]` in `/etc/docker/daemon.json`, restart Docker, align kubelet cgroup driver
- **`crictl` cannot reach `/run/cri-dockerd.sock`** → confirm path with `ls -la /run/cri-dockerd.sock` and package docs
- **Restarting Docker during production traffic** → drain the node first — restarts kill running containers underneath

---

## Learning objective

- Installed Docker and cri-dockerd, verified the CRI socket, and avoided pointing kubelet at the Docker API socket by mistake.

## Why this matters

This is a **bridge** stack for upgrades and legacy deps — you should recognize it in the field even if you do not choose it for new builds.

## Video close — fast validation

**What happens when you run this:**

Read-only: both units active, `crictl info` via the shim socket.

**Say:**

I mirror the module README’s Docker path: both services active, then `crictl info` through cri-dockerd.

**Run:**

```bash
sudo systemctl is-active docker
sudo systemctl is-active cri-docker
sudo crictl --runtime-endpoint unix:///run/cri-dockerd.sock info >/dev/null && echo "crictl: OK"
```

**Expected:**

Two `active` lines and `crictl: OK`.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/install-docker-cri-dockerd.sh` | Docker + cri-dockerd packages + enable units |
| `yamls/kubeadm-node-config-cri-dockerd.yaml` | Example `criSocket` for shim |
| `yamls/failure-troubleshooting.yaml` | Socket / daemon / endpoint issues |

---

## Next

[containerd](../1.2.1.1-containerd/README.md) or [CRI-O](../1.2.1.2-cri-o/README.md) for greenfield; then [1.2.2](../../1.2.2-installing-kubernetes-with-deployment-tools/README.md).
