# 003 Docker Engine (via cri-dockerd) â€” teaching transcript

## Intro

**Kubernetes 1.24+** removed **dockershim**. **Docker Engine** is not a native kubelet runtime anymore. **cri-dockerd** is a **CRI shim**: kubelet â†’ cri-dockerd â†’ Docker â†’ containers.

Use this path for **legacy or migration** only â€” **not** for new clusters (**containerd** or **CRI-O** is simpler).

**You need:** **Linux node**, **`sudo`**.

**Pick one runtime:** if you standardize on **containerd** or **CRI-O**, skip this lesson â€” see [01](../README.md).

**Teaching tip:** Each step includes **What happens when you run this** before **Run**. `scripts/install-docker-cri-dockerd.sh` repeats the install story in a header comment at the top of the file.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/02-production-environment/01-container-runtimes/03-docker-engine-via-cri-dockerd"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  chmod scripts  â†’  sudo install      â†’  both systemd   â†’  cri-dockerd   â†’  crictl info  â†’  cgroup grep  â†’  kubeadm YAML
                    Docker + shim         units active       socket          shim            docker info      grep
```

**Say:**

This path installs Docker plus the cri-dockerd shim, proves both services, proves the **CRI** socket (not `docker.sock`), runs `crictl` through the shim, checks Dockerâ€™s cgroup driver, then shows the kubeadm `criSocket` line.

---

## Step 1 â€” Open this lesson in the terminal

**What happens when you run this:**  
`cd`, `pwd`, `chmod +x scripts/*.sh` â€” lesson folder + executable scripts only.

**Say:**  
I move into the lesson folder and make scripts executable before installing anything.

**Run:**

```bash
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/02-production-environment/01-container-runtimes/03-docker-engine-via-cri-dockerd"
pwd
chmod +x scripts/*.sh
```

**Expected:**  
Path ends with `003-docker-engine-via-cri-dockerd`.

---

## Step 2 â€” Install Docker + cri-dockerd (root, idempotent)

**What happens when you run this:**  
`sudo ./scripts/install-docker-cri-dockerd.sh` apt-installs `docker.io` and `cri-dockerd`, enables/restarts Docker and cri-docker â€” see script header.

**Say:**  
Script installs packages and enables **docker** and **cri-docker** (socket + service). Idempotent package checks.

**Run:**

```bash
sudo ./scripts/install-docker-cri-dockerd.sh
```

**Expected:**  
Completes without error.

---

## Step 3 â€” Both services are up

**What happens when you run this:**  
`systemctl is-active` / `status` for Docker and cri-docker units â€” verifies both daemons are running.

**Say:**

Kubelet needs **both** Docker and the cri-dockerd service healthy â€” if either is down, pod sandboxes never start.

**Run:**

```bash
sudo systemctl is-active docker
sudo systemctl is-active cri-docker
sudo systemctl status docker --no-pager
sudo systemctl status cri-docker --no-pager
```

**Expected:**  
Both `active` (unit names may be `cri-docker` / `cri-docker.socket` depending on distro â€” follow `systemctl list-units | grep -i cri` if unsure).

---

## Step 4 â€” CRI socket (not Dockerâ€™s socket)

**What happens when you run this:**  
`ls -la /run/cri-dockerd.sock` confirms the **CRI** shim socket exists (distinct from Dockerâ€™s API socket).

**Say:**  
kubeadm must use **cri-dockerdâ€™s** CRI socket â€” **not** `/var/run/docker.sock`.

**Run:**

```bash
ls -la /run/cri-dockerd.sock
```

**Expected:**  
Socket exists.

---

## Step 5 â€” CRI responds through cri-dockerd

**What happens when you run this:**  
`crictl ... info` talks to cri-dockerdâ€™s endpoint and returns JSON â€” proves kubelet could use the same socket.

**Run:**

```bash
sudo crictl --runtime-endpoint unix:///run/cri-dockerd.sock info
```

**Expected:**  
JSON; no connection error.

---

## Step 6 â€” Cgroup driver check (Docker)

**What happens when you run this:**  
`docker info | grep -i cgroup` prints Dockerâ€™s cgroup driver line â€” read-only; you may need to change `daemon.json` and restart Docker if it shows **cgroupfs**.

**Say:**  
On older distros Docker may still use **cgroupfs**. kubelet should use **systemd** â€” they must match. Newer Ubuntu often defaults correctly.

**Run:**

```bash
docker info 2>/dev/null | grep -i cgroup
```

**Expected:**  
Ideally `systemd`. If you see **cgroupfs**, configure `/etc/docker/daemon.json` with `native.cgroupdriver=systemd`, restart Docker, **before** kubeadm (see your distro docs).

---

## Step 7 â€” Match kubeadm to cri-dockerd socket

**What happens when you run this:**  
`grep` on the example kubeadm node config shows the expected `criSocket` for cri-dockerd â€” no apply.

**Run:**

```bash
grep -n criSocket yamls/kubeadm-node-config-cri-dockerd.yaml
```

**Expected:**  
`unix:///run/cri-dockerd.sock` (or equivalent).

---

## Step 8 â€” Fast recap

**What happens when you run this:**  
`systemctl status` for both services and `crictl version` through the shim â€” final verification pass.

**Say:**

Last check: both daemons still up, `crictl` still answers on the shim socket â€” that is the path kubelet must use.

**Run:**

```bash
sudo systemctl status docker cri-docker --no-pager
sudo crictl --runtime-endpoint unix:///run/cri-dockerd.sock version
```

**Expected:**  
Services OK; `crictl` works.

---

## Troubleshooting

- **`kubeadm` config still references `/var/run/docker.sock`** â†’ replace with `unix:///run/cri-dockerd.sock` â€” kubelet talks CRI, not the Docker API
- **`cri-docker.service` inactive (dead)`** â†’ enable and start `cri-docker.socket` / `cri-docker.service` per your distro packages
- **`Cgroup Driver: cgroupfs` in `docker info`** â†’ set `"exec-opts": ["native.cgroupdriver=systemd"]` in `/etc/docker/daemon.json`, restart Docker, align kubelet cgroup driver
- **`crictl` cannot reach `/run/cri-dockerd.sock`** â†’ confirm path with `ls -la /run/cri-dockerd.sock` and package docs
- **Restarting Docker during production traffic** â†’ drain the node first â€” restarts kill running containers underneath

---

## Learning objective

- Installed Docker and cri-dockerd, verified the CRI socket, and avoided pointing kubelet at the Docker API socket by mistake.

## Why this matters

This is a **bridge** stack for upgrades and legacy deps â€” you should recognize it in the field even if you do not choose it for new builds.

## Video close â€” fast validation

**What happens when you run this:**

Read-only: both units active, `crictl info` via the shim socket.

**Say:**

I mirror the module READMEâ€™s Docker path: both services active, then `crictl info` through cri-dockerd.

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

[containerd](../01-containerd/README.md) or [CRI-O](../02-cri-o/README.md) for greenfield; then [02](../../02-installing-kubernetes-with-deployment-tools/README.md).
