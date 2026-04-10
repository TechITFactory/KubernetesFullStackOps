# 1.2.1.3 Docker Engine (via cri-dockerd)

- **Summary**: Install Docker Engine and `cri-dockerd` — the CRI shim that re-enables Docker as a Kubernetes runtime after dockershim removal in v1.24.
- **Content**: Why dockershim was removed, what `cri-dockerd` does, when to use this path, idempotent install automation.
- **Lab**: Run `install-docker-cri-dockerd.sh` as root, verify both services, apply the kubeadm node config using the `cri-dockerd` socket.

## Files

| Path | Purpose |
|------|---------|
| `scripts/install-docker-cri-dockerd.sh` | Idempotent: installs `docker.io` and `cri-dockerd`, enables both services |
| `yamls/kubeadm-node-config-cri-dockerd.yaml` | kubeadm `InitConfiguration` pointing kubelet at `/run/cri-dockerd.sock` |

## Quick Start

```bash
# Run as root on each node
sudo ./scripts/install-docker-cri-dockerd.sh

# Verify Docker
systemctl status docker

# Verify cri-dockerd
systemctl status cri-docker

# Verify socket
ls -la /run/cri-dockerd.sock
```

---

## Transcript — 10-Minute Lesson

### [0:00–0:45] Hook

This section is about a runtime you should use carefully — only when you have a specific reason.

Docker was the original container runtime for Kubernetes. For years, every Kubernetes tutorial started with "install Docker." Then in Kubernetes 1.24, support for Docker as a direct runtime was removed. Teams panicked. "Does Kubernetes no longer work with Docker?"

It does — but through a shim called `cri-dockerd`. Understanding why this happened, and when to use this path, is what this lesson is about.

---

### [0:45–2:30] The History — Why Docker Was Removed

In the early days of Kubernetes (2014–2019), Docker was the only container runtime that mattered. Kubernetes had a built-in translation layer called **dockershim** — code baked directly into kubelet that translated Kubernetes's internal calls into Docker API calls.

This worked but created problems:

1. **Maintenance burden** — the Kubernetes team had to maintain Docker-specific code in kubelet. Every Docker API change required a Kubernetes change.
2. **Feature mismatch** — Docker has features Kubernetes doesn't use: Swarm, Compose, image building, interactive terminal. Carrying these added complexity and attack surface.
3. **CRI was the solution** — the Container Runtime Interface was designed precisely to avoid this coupling. But maintaining dockershim alongside CRI sent a mixed message.

In **Kubernetes 1.20**, dockershim was deprecated with a warning. In **Kubernetes 1.24** (released May 2022), dockershim was removed.

If you ran a cluster on Docker and upgraded to 1.24 without migrating your runtime, your nodes stopped working.

**`cri-dockerd`** is the community-maintained replacement. It is a separate process that wraps the Docker API and exposes a CRI socket. Kubernetes talks to `cri-dockerd` via CRI; `cri-dockerd` translates that to Docker API calls.

```
kubelet  →  CRI socket  →  cri-dockerd  →  Docker Engine  →  runc  →  container
```

The chain is longer — which is why this is not the recommended path for new clusters. But it works.

---

### [2:30–3:45] When to Use This Path

**Use `cri-dockerd` if:**
- You have existing infrastructure running Docker that is expensive to migrate.
- Your team has tooling (monitoring, log shipping, build pipelines) that depends on the Docker socket or Docker CLI.
- You are running a hybrid cluster where some nodes use Docker and others use containerd.

**Do not use `cri-dockerd` if:**
- You are building a new cluster. Use `containerd` or `CRI-O` instead.
- You want simplicity — the extra process adds one more thing that can fail.
- You care about performance — the extra translation hop has measurable latency.

The `cri-dockerd` project is maintained by Mirantis (the company that acquired Docker Enterprise). It is actively developed and production-safe, but it is a bridge technology, not a long-term architecture.

---

### [3:45–5:15] Two Sockets, Two Services

After installation, two services run on the node:

**Docker Engine** — the container daemon. Socket at `/var/run/docker.sock`. Used by Docker CLI, build tools, and legacy tooling.

**cri-dockerd** — the CRI shim. Socket at `/run/cri-dockerd.sock`. Used exclusively by kubelet.

These are separate processes. Docker does not know about Kubernetes; `cri-dockerd` translates between them.

Your kubeadm config must reference the `cri-dockerd` socket:

```yaml
nodeRegistration:
  criSocket: unix:///run/cri-dockerd.sock
```

If you accidentally point kubeadm at `/var/run/docker.sock` (the Docker socket, not the CRI socket), kubeadm will fail — Docker's socket does not speak CRI.

---

### [5:15–6:30] The Install Script — Line by Line

```bash
for pkg in docker.io cri-dockerd; do
  if ! package_installed "$pkg"; then
    apt-get install -y "$pkg"
  else
    echo "$pkg already installed. Skipping."
  fi
done
```
Idempotent loop — checks each package individually before installing. You can add more packages to this loop without refactoring.

```bash
systemctl enable --now docker
systemctl enable --now cri-docker.socket
systemctl restart docker
systemctl restart cri-docker
```
Both services must be enabled and running. Note `cri-docker.socket` (the systemd socket activation unit) and `cri-docker` (the service unit) are separate — both must be enabled.

`systemctl restart` is safe here because at this point no Kubernetes workloads are running on the node. Never restart these services on a live node with running pods without draining it first.

---

### [6:30–7:45] Cgroup Driver Note

Unlike `containerd` (where we patched `SystemdCgroup = true`) and CRI-O (where we wrote a drop-in config), Docker's cgroup driver is configured in the Docker daemon config at `/etc/docker/daemon.json`:

```json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
```

The install script does not write this — it installs packages and starts services. On Ubuntu 22.04 and newer, Docker defaults to `systemd` cgroup driver automatically. On older distributions, you may need to add this manually before running kubeadm.

Check with:
```bash
docker info | grep -i cgroup
```

If it shows `Cgroup Driver: cgroupfs`, add the daemon.json config and restart Docker before proceeding.

---

### [7:45–9:00] Real World — Migration Stories

The most common real-world use of `cri-dockerd` is **cluster migration** — moving existing clusters from Docker to a proper CRI runtime.

A typical migration path at a company:
1. Nodes running Kubernetes 1.23 with dockershim.
2. Cluster upgraded to 1.24 — dockershim removed.
3. `cri-dockerd` installed as an emergency measure to unblock the upgrade.
4. Over the next quarter, nodes are drained and reimaged with `containerd`.
5. `cri-dockerd` decommissioned.

That is the intended use: a **bridge**, not a destination.

Some teams stay on `cri-dockerd` longer because their build pipelines depend on the Docker socket — CI systems that do `docker build` inside the cluster. Even in those cases, the trend is to move to tools like `kaniko`, `buildkit`, or `ko` that build OCI images without a Docker daemon.

---

### [9:00–10:00] Recap

- **dockershim** was removed in Kubernetes 1.24. Docker Engine is no longer a direct kubelet runtime.
- **`cri-dockerd`** is a CRI shim — it wraps Docker's API and exposes a CRI socket at `/run/cri-dockerd.sock`.
- **Two sockets**: `/var/run/docker.sock` (Docker) and `/run/cri-dockerd.sock` (CRI). kubeadm must point at the CRI socket.
- **When to use**: legacy Docker environments, migration bridges. Not recommended for new clusters.
- Install script is **idempotent** — checks each package before installing, safe to re-run.

## Video close — fast validation

```bash
sudo systemctl status docker --no-pager
sudo systemctl status cri-docker --no-pager
sudo crictl --runtime-endpoint unix:///run/cri-dockerd.sock info
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common cri-dockerd socket, Docker daemon, and kubelet runtime endpoint issues.
- **Check cgroup driver** manually on older distributions — Docker may default to `cgroupfs`.

Next: 1.2.2 — Installing Kubernetes with kubeadm, where we use the runtime you just installed to bootstrap a full cluster.
