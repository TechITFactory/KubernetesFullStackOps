# 1.2.1.2 CRI-O

- **Summary**: Install `CRI-O`, the runtime purpose-built for Kubernetes, configure the systemd cgroup driver, and verify the CRI socket kubelet will use.
- **Content**: CRI-O's design philosophy, how it differs from containerd, systemd cgroup configuration, idempotent install automation.
- **Lab**: Run `install-crio.sh` as root, verify the socket at `/var/run/crio/crio.sock`, apply the kubeadm node config.

## Files

| Path | Purpose |
|------|---------|
| `scripts/install-crio.sh` | Idempotent: installs CRI-O + runc, writes cgroup manager config, restarts service |
| `yamls/kubeadm-node-config-crio.yaml` | kubeadm `InitConfiguration` pointing kubelet at the CRI-O socket |

## Quick Start

```bash
# Run as root on each node
sudo ./scripts/install-crio.sh

# Verify service
systemctl status crio

# Verify socket
ls -la /var/run/crio/crio.sock

# Verify CRI
sudo crictl --runtime-endpoint unix:///var/run/crio/crio.sock info
```

---

## Transcript — 10-Minute Lesson

### [0:00–0:45] Hook

In the previous section we installed `containerd` — a runtime that started as part of Docker and was later extracted for broader use. It works well, but it carries history from a world that predates Kubernetes.

`CRI-O` was built from scratch with a single question: "what does Kubernetes actually need from a container runtime?" Nothing more, nothing less.

If you work in a Red Hat, OpenShift, or RHEL environment — or if you want the most tightly Kubernetes-aligned runtime available — this is the lesson for you.

---

### [0:45–2:30] What Is CRI-O and Why Does It Exist?

The Container Runtime Interface (CRI) was introduced in Kubernetes 1.5 to decouple Kubernetes from Docker. Before CRI, Kubernetes had direct, hard-coded Docker calls baked into kubelet. That was a maintenance problem — every Docker change could break Kubernetes.

CRI made runtimes pluggable. Any runtime that speaks the CRI protocol can work with Kubernetes.

`containerd` and Docker both implemented CRI. But they both carried non-Kubernetes features — image building, CLI tools, swarm mode, compose. CRI-O said: why carry all that weight?

**CRI-O's design principles:**
- Implements CRI and nothing else. No image building. No CLI for end users. No features Kubernetes doesn't need.
- One runtime version per Kubernetes minor version — CRI-O 1.29 is tested against Kubernetes 1.29.
- Uses `runc` as the low-level runtime (the same OCI runtime that containerd uses).
- Pulls images using containers/image, the same library used by Podman and Buildah.

**Analogy**: containerd is a Swiss Army knife — useful for many tasks. CRI-O is a scalpel — one job, done perfectly.

**Real-world usage**: CRI-O is the default runtime in **OpenShift** (Red Hat's Kubernetes distribution), used by thousands of enterprises in regulated industries (finance, healthcare, government). It is also increasingly used in vanilla Kubernetes clusters where operational simplicity matters.

---

### [2:30–4:00] CRI-O and Kubernetes Version Alignment

One of CRI-O's strongest properties is explicit Kubernetes version tracking. The CRI-O project maintains separate branches that map directly to Kubernetes minor versions:

| Kubernetes | CRI-O |
|-----------|-------|
| 1.29 | 1.29.x |
| 1.30 | 1.30.x |
| 1.31 | 1.31.x |

When you upgrade Kubernetes, you upgrade CRI-O to the matching minor version. There is no guesswork about compatibility.

This is different from containerd, which has its own versioning independent of Kubernetes. containerd 1.7 supports multiple Kubernetes versions, which is flexible but requires you to check the support matrix yourself.

For teams that want clear upgrade paths and explicit compatibility guarantees, CRI-O's 1:1 version mapping is a meaningful operational advantage.

---

### [4:00–5:30] The Cgroup Configuration

Like containerd, CRI-O must use the `systemd` cgroup driver to match kubelet on modern Linux systems.

Look at the install script:

```bash
mkdir -p "$CRIO_CONF_DIR"
cat > "$CRIO_CONF_DIR/02-cgroup-manager.conf" <<'EOF'
[crio.runtime]
cgroup_manager = "systemd"
conmon_cgroup = "pod"
EOF
```

CRI-O uses a drop-in configuration directory at `/etc/crio/crio.conf.d/`. Files in that directory are merged in alphabetical order. The `02-` prefix ensures this file loads after the base config but can be overridden by files with higher numbers.

`conmon_cgroup = "pod"` tells CRI-O to place the container monitor process (`conmon`) in the pod's cgroup, not a separate one. This is required for correct systemd cgroup accounting.

This is a write-always operation in the script — the configuration file is always written fresh. Because it is a small, idempotent file with no variable content, rewriting it on every run is safe and simpler than patching.

---

### [5:30–7:00] The Install Script — Line by Line

```bash
require_root
```
Same pattern as the containerd script — root required, checked at the start.

```bash
if ! package_installed cri-o; then
  apt-get install -y cri-o cri-o-runc
else
  echo "CRI-O already installed. Skipping."
```
Idempotent package install — `dpkg -s cri-o` checks before installing. `cri-o-runc` is the OCI runtime adapter that lets CRI-O execute containers via `runc`.

```bash
mkdir -p "$CRIO_CONF_DIR"
cat > "$CRIO_CONF_DIR/02-cgroup-manager.conf" ...
```
Creates the config drop-in directory and writes the cgroup configuration. Idempotent in effect — the same content is always written.

```bash
systemctl enable --now crio
systemctl restart crio
```
Enable for persistence across reboots, restart to apply the new cgroup config.

---

### [7:00–8:15] Verify Before Proceeding

```bash
# Service is active
systemctl status crio

# Socket exists
ls -la /var/run/crio/crio.sock

# CRI responds
sudo crictl --runtime-endpoint unix:///var/run/crio/crio.sock info

# Confirm cgroup manager in effect
sudo crictl info | grep -i cgroup
```

The `crictl info` output should show `"cgroupDriver": "systemd"`. If it shows `cgroupfs`, the cgroup config drop-in was not applied. Check `journalctl -u crio -n 50`.

---

### [8:15–9:30] Real World — CRI-O in Production

**OpenShift** is the most prominent CRI-O deployment. Red Hat chose CRI-O as the default because it perfectly matches their OCI-native, Kubernetes-first philosophy. Every OpenShift cluster worldwide runs CRI-O.

Beyond OpenShift, CRI-O appears in:

- **Government and regulated-sector clusters** — where minimising the attack surface is a compliance requirement. CRI-O exposes no unnecessary APIs or features, reducing the attack surface compared to a full-featured runtime.
- **Academic and research computing** — HPC environments where tight coupling between the Kubernetes scheduler and the runtime is needed.
- **Teams upgrading from OpenShift** — who want to maintain runtime consistency when moving to vanilla Kubernetes.

**Operational note**: because CRI-O has fewer moving parts, it is also easier to debug. There is no separate image store separate from CRI-O's own layer — what you see in `crictl images` is exactly what is on disk.

---

### [9:30–10:00] Recap

- **CRI-O** = purpose-built Kubernetes runtime. Implements CRI and nothing else. No Docker heritage.
- **Version alignment** — CRI-O 1.X matches Kubernetes 1.X. Clear, predictable upgrade path.
- **`cgroup_manager = "systemd"`** configured via drop-in at `/etc/crio/crio.conf.d/02-cgroup-manager.conf`. Must match kubelet.
- **CRI socket**: `/var/run/crio/crio.sock` — reference this in your kubeadm node config.
- Install script is **idempotent** — skips package install if already present, writes config fresh each time.

Next: 1.2.1.3 — Docker Engine via `cri-dockerd`, for environments with an existing Docker dependency.
