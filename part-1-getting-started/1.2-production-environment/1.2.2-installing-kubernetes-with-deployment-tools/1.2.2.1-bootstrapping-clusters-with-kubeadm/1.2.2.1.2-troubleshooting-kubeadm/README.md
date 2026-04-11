# 1.2.2.1.2 Troubleshooting kubeadm

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/part-1-getting-started/1.2-production-environment/1.2.2-installing-kubernetes-with-deployment-tools/1.2.2.1-bootstrapping-clusters-with-kubeadm/1.2.2.1.2-troubleshooting-kubeadm"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  land in lesson folder  →  run diagnostics script  →  read bundle  →  only then change node state
```

**Say:**

I always capture evidence before I restart kubelet or re-run kubeadm — the diagnostic bundle is the snapshot I share with teammates.

---

- **Summary**: Collect a complete diagnostic bundle from a node before making any changes — preserving the evidence that explains why `kubeadm init` or `kubeadm join` failed.
- **Content**: What to capture and why, the diagnostic script structure, interpreting kubelet logs and preflight signals, swap and port checks.
- **Lab**: Run `collect-kubeadm-diagnostics.sh` on a failing node and use the output bundle to identify the root cause.

## Files

| Path | Purpose |
|------|---------|
| `scripts/collect-kubeadm-diagnostics.sh` | Captures system state into a directory of text files — kubelet logs, runtime status, swap, networking, tool versions |

**Teaching tip:** **What happens when you run this** summarizes effects before you paste. Match **WHAT THIS DOES WHEN YOU RUN IT** in `scripts/collect-kubeadm-diagnostics.sh`.

## Quick Start

**What happens when you run this:**  
- `collect-kubeadm-diagnostics.sh` — creates `./kubeadm-diagnostics/` (or `OUTPUT_DIR`) and writes one `.txt` per capture command (kubelet logs, `systemctl`, `ip`, `ss`, versions, etc.); non-zero commands still save output.  
- `ls` / `cat` — read those files locally; no node config changes.

```bash
# Run as root on the problematic node
sudo ./scripts/collect-kubeadm-diagnostics.sh

# Review the bundle
ls ./kubeadm-diagnostics/
cat ./kubeadm-diagnostics/kubelet-logs.txt
cat ./kubeadm-diagnostics/kubelet-status.txt
```

---

## Transcript — 10-Minute Lesson

### [0:00–0:45] Hook

`kubeadm init` fails. The error message is cryptic. Your instinct is to start changing things — restart services, edit configs, try again.

Stop. That instinct is wrong.

When a system fails, the failure state contains the evidence you need. The moment you start changing things, you destroy that evidence. You make it harder to understand what went wrong — and you risk introducing new problems on top of the original one.

The right first move is always: **capture the state, then analyse**.

---

### [0:45–2:00] Why Collect Before You Change

Imagine a car that won't start. A good mechanic plugs in the diagnostic tool first — reads the fault codes, checks sensor data — before touching anything. A bad mechanic starts swapping parts hoping something works.

The diagnostic script is your fault code reader for a Kubernetes node. It captures everything relevant to kubeadm bootstrap failures in a single run. After capturing, you can:

- Analyse without time pressure.
- Share the bundle with a teammate or support team.
- Compare before-and-after state when you do make changes.
- Identify the root cause without guessing.

**Real rule**: never restart kubelet, never re-run kubeadm, never edit a config file until you have a diagnostic bundle. Five minutes of capture can save hours of debugging.

---

### [2:00–4:00] What the Script Captures

The script uses a `run_capture` helper:

```bash
run_capture() {
  local name="$1"
  shift
  if "$@" >"$OUTPUT_DIR/$name.txt" 2>&1; then
    echo "[OK] $name"
  else
    echo "[WARN] $name captured with non-zero exit"
  fi
}
```

Each capture runs a command and writes stdout + stderr to a named file. If the command fails (non-zero exit), it logs a warning but continues — a failed command output is still useful data.

**What is captured and why:**

| File | Command | What it tells you |
|------|---------|------------------|
| `uname.txt` | `uname -a` | Kernel version — some K8s features require minimum kernel versions |
| `kubelet-status.txt` | `systemctl status kubelet` | Whether kubelet is running, crash-looping, or disabled |
| `kubelet-logs.txt` | `journalctl -u kubelet -n 300` | The last 300 log lines — error messages from kubeadm init attempts |
| `container-runtime.txt` | `systemctl status containerd` | Runtime health — a dead runtime means kubelet cannot start pods |
| `crio-status.txt` | `systemctl status crio` | CRI-O health if CRI-O is the runtime |
| `cri-docker-status.txt` | `systemctl status cri-docker` | cri-dockerd health if Docker is the runtime |
| `swap.txt` | `swapon --show` | Swap state — kubeadm requires swap to be off |
| `modules.txt` | `lsmod` | Kernel modules — `br_netfilter` and `overlay` are required |
| `ip-address.txt` | `ip addr` | Node IP addresses — needed to verify correct advertise address |
| `routes.txt` | `ip route` | Routing table — pod CIDR routing issues show here |
| `ports.txt` | `ss -tulpn` | Listening ports — port conflicts block kubeadm preflight |
| `kubeadm-version.txt` | `kubeadm version` | Version verification |
| `kubectl-version.txt` | `kubectl version --client` | Version verification |

---

### [4:00–5:30] Reading the Most Important Files

**`kubelet-logs.txt`** — start here. Search for `error`, `failed`, `unable`:

```
error: failed to run Kubelet: misconfiguration: kubelet cgroup driver: "cgroupfs" is different from docker cgroup driver: "systemd"
```
→ Cgroup driver mismatch. Fix: align cgroup driver in runtime and kubelet config.

```
failed to create containerd task: failed to create shim task: OCI runtime create failed
```
→ Runtime issue. Check `container-runtime.txt`.

```
failed to load Kubelet config file: open /var/lib/kubelet/config.yaml: no such file or directory
```
→ kubeadm has not initialised this node yet. Normal if this is pre-init.

**`swap.txt`** — if this shows any swap partitions or files, kubeadm will fail preflight. Fix: `swapoff -a` and remove the swap entry from `/etc/fstab`.

**`ports.txt`** — look for anything listening on `6443` (API server), `2379-2380` (etcd), `10250` (kubelet), `10257` (controller-manager), `10259` (scheduler). A conflict means another process has claimed the port kubeadm needs.

---

### [5:30–6:45] Common Preflight Failures

kubeadm runs preflight checks before doing anything. These are the most common:

| Preflight error | Root cause | Fix |
|----------------|-----------|-----|
| `[ERROR Swap]` | Swap enabled | `swapoff -a`, remove from `/etc/fstab` |
| `[ERROR CRI]` | Runtime not running or wrong socket | Check runtime service status |
| `[ERROR Port-6443]` | Port conflict | Find and stop the conflicting process |
| `[ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]` | `br_netfilter` not loaded | `modprobe br_netfilter` + persist in `/etc/modules-load.d/` |
| `[ERROR NumCPU]` | Node has fewer than 2 CPUs | Add CPUs to the VM or use `--ignore-preflight-errors=NumCPU` for lab-only |
| `[ERROR Mem]` | Less than 1700MB RAM | Increase RAM |

All of these appear in `kubelet-logs.txt` and in the kubeadm output itself. The diagnostic bundle captures the state that produced these errors.

---

### [6:45–8:00] The Kernel Modules Requirement

`modules.txt` (from `lsmod`) lets you verify two kernel modules that Kubernetes requires:

```bash
# These must appear in lsmod output
br_netfilter   # enables iptables to see bridged traffic (required for pod networking)
overlay        # used by containerd and CRI-O for container filesystem layers
```

Load them and persist across reboots:

```bash
modprobe br_netfilter
modprobe overlay

cat > /etc/modules-load.d/kubernetes.conf <<EOF
br_netfilter
overlay
EOF
```

Also set the sysctl values kubeadm needs:

```bash
cat > /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system
```

These are prerequisites that should be applied before installing kubeadm. If your node is missing them, the diagnostic bundle tells you — and the fix is two commands.

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common preflight, CRI, CNI, and kubelet startup failures.

---

### [8:00–9:15] Real World — Diagnostics in On-Call Runbooks

Production Kubernetes teams maintain **runbooks** — documented procedures for known failure modes. The diagnostic collection script is a standard first step in most runbooks:

1. Node fails to join cluster → run diagnostics → share bundle in incident channel.
2. kubelet crash-loops after upgrade → run diagnostics before rolling back.
3. kubeadm init times out → run diagnostics to identify which component blocked.

Some teams automate this: when a node fails its health check, a systemd service triggers the diagnostic script and uploads the bundle to an S3 bucket or Slack channel automatically. On-call engineers get the bundle before they even open a terminal.

The script's `[OK]` / `[WARN]` output format is intentional — it is designed to be readable in a Slack message or log file at 3am.

---

### [9:15–10:00] Recap

- **Capture before you change** — the diagnostic bundle preserves failure evidence.
- **`collect-kubeadm-diagnostics.sh`** — runs 13 commands, writes each to a named file, warns on non-zero exits but continues.
- **Start with `kubelet-logs.txt`** — it contains the most specific error messages.
- **Check swap, ports, and kernel modules** — these are the most common kubeadm preflight blockers.
- The `run_capture` helper is a reusable pattern — add commands to it for any node-level diagnostic you need.

Next: 1.2.2.1.3 — Creating a Cluster with kubeadm, where we run `kubeadm init` and join worker nodes.

## Video close — fast validation

**What happens when you run this:**  
Re-captures diagnostics (overwrites/merges files in the output dir), lists them, shows kubelet unit status, prints first 40 lines of kubelet log capture — all read-only except regenerating the bundle files.

```bash
sudo ./scripts/collect-kubeadm-diagnostics.sh
ls -la ./kubeadm-diagnostics/
sudo systemctl status kubelet --no-pager
head -n 40 ./kubeadm-diagnostics/kubelet-logs.txt
```
