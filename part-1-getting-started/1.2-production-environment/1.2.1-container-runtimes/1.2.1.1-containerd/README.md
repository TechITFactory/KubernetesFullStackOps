# 1.2.1.1 containerd

- **Summary**: Install `containerd`, configure it as a CRI-compatible runtime with the systemd cgroup driver, and verify the socket path kubelet will use.
- **Content**: What a container runtime is, why `SystemdCgroup = true` is mandatory, idempotent install automation, CRI socket validation.
- **Lab**: Run `install-containerd.sh` as root, confirm the socket exists at `/run/containerd/containerd.sock`, apply the kubeadm node config.

## Files

| Path | Purpose |
|------|---------|
| `scripts/install-containerd.sh` | Idempotent: installs containerd, generates default config, patches `SystemdCgroup`, restarts service |
| `yamls/kubeadm-node-config-containerd.yaml` | kubeadm `InitConfiguration` pointing kubelet at the containerd CRI socket |

## Quick Start

```bash
# Run as root on each node
sudo ./scripts/install-containerd.sh

# Verify the socket exists
ls -la /run/containerd/containerd.sock

# Verify CRI
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock info
```

---

## Transcript — 10-Minute Lesson

### [0:00–0:45] Hook

You have a Kubernetes cluster in mind. You have nodes — servers, virtual machines, or cloud instances — ready to join. But Kubernetes itself does not run containers. It needs something on every node that can take an image, start it as a process, and report back.

That something is a **container runtime**. And the runtime you install here, before you even touch kubeadm, determines how every pod on that node lives and dies.

In this lesson we install `containerd` — the most widely deployed production runtime on the planet.

---

### [0:45–2:30] What Is a Container Runtime?

Let's start with an analogy. Kubernetes is like a city planning department — it decides where buildings go, how many are built, when to tear them down. But the planning department doesn't pour concrete. It calls a **construction company** that does the actual physical work.

The container runtime is that construction company. Kubernetes tells it: "start this container image on this node." The runtime does the work: downloads the image, sets up the filesystem, starts the process, manages its lifecycle.

Before Kubernetes 1.24, it could talk to Docker directly. That created a mess — Docker wasn't designed for Kubernetes, there was an awkward translation layer called dockershim, and it was removed. Kubernetes now requires runtimes to implement the **Container Runtime Interface (CRI)** — a standard API.

Three runtimes implement CRI today:

| Runtime | Designed for K8s? | Default in |
|---------|------------------|-----------|
| `containerd` | Partly (extracted from Docker) | EKS, GKE, AKS, kubeadm |
| `CRI-O` | Yes — built solely for K8s | OpenShift |
| Docker + `cri-dockerd` | No — needs a shim | Legacy environments |

`containerd` is the right default for new clusters. It is battle-tested, lightweight, supported by every major cloud provider, and is what kubeadm assumes by default.

---

### [2:30–4:00] The CRI Socket — How kubelet Finds the Runtime

When kubelet starts on a node, it needs to know where to find the runtime. It does this through a **CRI socket** — a Unix socket file on the filesystem.

For `containerd`, that socket is at:
```
/run/containerd/containerd.sock
```

kubelet connects to this socket and sends instructions: "start this pod," "kill that container," "what is the status of this container?" The runtime handles everything; kubelet just gives orders.

This is why, in `kubeadm-node-config-containerd.yaml`, you see:

```yaml
nodeRegistration:
  criSocket: unix:///run/containerd/containerd.sock
```

You are telling kubeadm: when you register this node, tell kubelet to use this socket. If the socket path is wrong, kubelet cannot talk to the runtime, and the node never becomes Ready.

---

### [4:00–5:45] Why `SystemdCgroup = true` Is Not Optional

This is the single most common reason kubeadm clusters fail to start: the cgroup driver mismatch.

Here is what is happening. Linux uses **cgroups** to limit CPU and memory for processes. There are two ways to manage cgroups: through `systemd` or directly through `cgroupfs`. On modern Linux systems (Ubuntu 22.04+, RHEL 9+), `systemd` owns cgroup management.

If `containerd` manages cgroups via `cgroupfs` but `kubelet` manages them via `systemd`, they fight each other. Pods get killed. Nodes become unstable. The error messages are cryptic.

The fix is simple: both must use `systemd`. In the containerd config:

```toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
  SystemdCgroup = true
```

The install script patches this automatically:

```python
if 'SystemdCgroup = false' in text:
    text = text.replace('SystemdCgroup = false', 'SystemdCgroup = true')
```

And in the kubeadm config, the KubeletConfiguration also sets `cgroupDriver: systemd`. Both sides must agree. The script handles containerd; the YAML handles kubelet.

---

### [5:45–7:15] The Install Script — Line by Line

```bash
require_root
```
containerd needs root to install system packages and manage systemd services. The script checks `EUID` and exits immediately if not root — a clear error beats a mysterious permission failure five steps in.

```bash
if ! package_installed containerd; then
  apt-get install -y containerd
else
  echo "containerd already installed. Skipping."
```
**Idempotency.** `dpkg -s containerd` checks whether the package is installed. If yes, skip the install. Run this script on a node that already has containerd — nothing breaks, nothing duplicates.

```bash
if [[ ! -f "$CONTAINERD_CONFIG" ]]; then
  containerd config default > "$CONTAINERD_CONFIG"
fi
```
Generate the default config only if one does not already exist. Preserves any manual edits on subsequent runs.

```bash
python3 - <<'PY'
...patch SystemdCgroup and disabled_plugins...
PY
```
Python reads the config file, patches two values, and writes it back only if changes were needed. Idempotent: if `SystemdCgroup = true` is already there, the file is untouched.

```bash
systemctl enable --now containerd
systemctl restart containerd
```
Enable the service so it survives reboots, then restart to pick up the config changes.

---

### [7:15–8:30] Verify Before Proceeding

After the script runs, confirm the runtime is healthy before touching kubeadm:

```bash
# Socket exists
ls -la /run/containerd/containerd.sock

# Service status
systemctl status containerd

# CRI endpoint responds
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock info
```

`crictl info` outputs containerd's status in JSON. If you see `"status": "ok"`, the CRI is working. If you see connection errors, check `journalctl -u containerd -n 50` for the root cause.

Run these checks on every node before proceeding to kubeadm installation.

---

### [8:30–9:30] Real World — Where containerd Is Deployed

`containerd` is the default runtime for:

- **Amazon EKS** — all managed node groups run containerd.
- **Google GKE** — default since GKE 1.19.
- **Azure AKS** — replaced Docker in AKS 1.21.
- **kubeadm clusters** — detected automatically when containerd's socket exists.

At companies running self-managed clusters — banks, telcos, enterprises with compliance requirements — `containerd` is the near-universal choice for new infrastructure. It is stable, well-documented, and has years of production hardening behind it.

The `SystemdCgroup = true` requirement is the same everywhere. If you ever see a node stuck in `NotReady` with kubelet failing to start pods, cgroup driver mismatch is the first thing to check.

---

### [9:30–10:00] Recap

- A **container runtime** is what actually runs containers on a node. Kubernetes uses CRI to talk to it.
- **containerd** is the default, most widely deployed CRI runtime — used by all major cloud providers.
- **CRI socket** `/run/containerd/containerd.sock` is how kubelet finds containerd. Must match the kubeadm node config.
- **`SystemdCgroup = true`** must be set in both containerd config and kubelet config. Mismatch = node instability.
- The install script is **idempotent** — checks before installing, patches only what is needed, safe to run again.

Next: 1.2.1.2 — CRI-O, the runtime built exclusively for Kubernetes with no Docker lineage.

## Video close — fast validation

```bash
sudo systemctl status containerd --no-pager
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock info
kubectl get nodes -o wide
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common containerd install, CRI socket, and kubelet integration failures.
