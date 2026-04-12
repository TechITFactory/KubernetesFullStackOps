# Configuring each kubelet in your Cluster Using kubeadm

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/02-production-environment/06-kubeadm-kubelet-config"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  edit KubeletConfiguration patch  →  apply via kubeadm drop-in  →  restart kubelet  →  verify effective config
```

**Say:**

Cgroup driver and eviction settings must match across nodes — kubeadm’s drop-in directory is how I keep that uniform.

---

- **Summary**: Apply a consistent `KubeletConfiguration` across all cluster nodes using kubeadm's drop-in mechanism, ensuring cgroup driver, eviction thresholds, and authentication settings are uniform.
- **Content**: What kubelet is, why consistent configuration matters, the kubeadm drop-in directory, key KubeletConfiguration fields, applying and verifying.
- **Lab**: Run `apply-kubelet-config.sh` as root on a node, restart kubelet, verify the effective configuration.

## Files

| Path | Purpose |
|------|---------|
| `scripts/apply-kubelet-config.sh` | Idempotent: writes kubelet config to the kubeadm drop-in directory, restarts kubelet |
| `yamls/kubeletconfiguration.yaml` | KubeletConfiguration with cgroup driver, eviction thresholds, and authentication settings |

**Teaching tip:** **WHAT THIS DOES WHEN YOU RUN IT** is in `scripts/apply-kubelet-config.sh`. The `kubectl proxy` + `curl configz` path exposes kubelet config over the API — use a real node name and stop proxy when done.

## Quick Start

**What happens when you run this:**  
- `apply-kubelet-config.sh` — copies `yamls/kubeletconfiguration.yaml` to `/var/lib/kubelet/config.yaml`, **restarts kubelet** (brief disruption risk on that node).  
- `kubectl proxy` — starts local HTTP proxy to the API in background; `curl .../configz` reads kubelet’s live config via the apiserver **node proxy** (replace `<node-name>`).

```bash
# Run as root on each node (control-plane and workers)
sudo ./scripts/apply-kubelet-config.sh

# Verify effective config
sudo kubectl proxy &
curl -s http://localhost:8001/api/v1/nodes/<node-name>/proxy/configz | python3 -m json.tool | grep cgroupDriver
```

---

## Transcript — 10-Minute Lesson

### [0:00–0:45] Hook

We have configured the API server, the scheduler, the controller-manager, kube-proxy. There is one more component that runs on every single node in the cluster — control plane and workers alike — and it needs its own configuration: **kubelet**.

Inconsistent kubelet configuration across nodes is a silent source of production problems. One node using `cgroupfs`, another using `systemd`. One node with aggressive eviction, another with none. Same cluster, wildly different behaviour.

This lesson is about making kubelet configuration uniform, explicit, and managed.

---

### [0:45–2:00] What kubelet Does

**kubelet** is the agent that runs on every node. It is the bridge between the Kubernetes control plane and the container runtime on that node.

Its core responsibilities:
1. **Watch the API server** for pod specifications assigned to this node.
2. **Tell the runtime** to start, stop, or inspect containers.
3. **Report node status** back to the API server — CPU, memory usage, conditions, events.
4. **Run health checks** — liveness and readiness probes, restarting containers that fail.
5. **Manage volumes** — mounting and unmounting storage as pods are created and deleted.

kubelet is not optional. Every node must run kubelet. If kubelet crashes, the node's pods become unmanaged — they keep running but cannot be updated, restarted, or removed by Kubernetes.

---

### [2:00–3:30] The kubeadm Drop-in Directory

kubeadm manages kubelet configuration through a **drop-in directory**:

```
/etc/systemd/system/kubelet.service.d/
```

Files in this directory are loaded by systemd as overrides for the base kubelet service. kubeadm creates `10-kubeadm.conf` here during `init` and `join`, which points kubelet at the cluster config.

For `KubeletConfiguration`, kubeadm writes a config file that kubelet reads at startup:

```
/var/lib/kubelet/config.yaml
```

The `apply-kubelet-config.sh` script writes to this location. Any time you update this file and restart kubelet, the new settings take effect.

This is how kubeadm intends configuration to be managed — not by editing kubelet's command-line flags in the systemd unit, but by writing a structured `KubeletConfiguration` manifest.

---

### [3:30–5:00] Key KubeletConfiguration Fields

**`cgroupDriver`** — must match the container runtime. Set to `systemd` on all modern Linux systems:
```yaml
cgroupDriver: systemd
```

**Eviction thresholds** — when a node runs low on resources, kubelet evicts pods to protect the node. Thresholds define when eviction starts:
```yaml
evictionHard:
  memory.available: "200Mi"
  nodefs.available: "10%"
  nodefs.inodesFree: "5%"
```
`200Mi` of available memory triggers pod eviction. This protects against OOM kills that crash the node. Without eviction, the kernel OOM killer may kill kubelet or system processes instead of pods.

**`authentication` and `authorization`** — kubelet exposes an API on port 10250. Securing it:
```yaml
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
authorization:
  mode: Webhook
```
`anonymous: false` + `Webhook` mode means every request to the kubelet API must be authenticated and authorised through the Kubernetes API server. Without this, anyone who can reach port 10250 on a node can exec into pods.

**`maxPods`** — maximum pods schedulable on this node. Default is 110. Adjust based on node size:
```yaml
maxPods: 110
```

---

### [5:00–6:15] The Apply Script

`apply-kubelet-config.sh` reads the `KubeletConfiguration` YAML and places it in the correct location. The pattern should be familiar:

- Checks it is running as root.
- Verifies `kubectl` and `kubelet` are available.
- Checks cluster reachability.
- Copies the config to `/var/lib/kubelet/config.yaml`.
- Restarts kubelet.
- Waits and verifies kubelet is active.

**Idempotency**: copying a config file and restarting kubelet is idempotent. The same config applied twice produces the same state. Restarting kubelet on a node causes a brief window where pods may be restarted — on a live cluster, drain the node first:

```bash
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
sudo ./scripts/apply-kubelet-config.sh
kubectl uncordon <node-name>
```

In production, never restart kubelet on a running node without draining it first.

---

### [6:15–7:15] Applying to All Nodes

In a cluster of 10+ nodes, you do not run this script manually on each node. You use:

**Ansible**:
```yaml
- name: Apply kubelet config
  copy:
    src: kubeletconfiguration.yaml
    dest: /var/lib/kubelet/config.yaml
  notify: restart kubelet
```

**kubeadm upgrade** — when you upgrade a cluster with kubeadm, it automatically applies the new KubeletConfiguration to each node as part of the upgrade process.

**DaemonSet** — some teams deploy a DaemonSet that writes kubelet configuration and handles restarts. This is a more advanced pattern suitable for clusters where dynamic node configuration is needed.

---

### [7:15–8:15] Verifying the Effective Configuration

After applying, verify kubelet is actually running with the new settings. Do not assume the file write succeeded:

```bash
# kubelet is active
systemctl status kubelet

# Effective config via kubelet configz endpoint
sudo kubectl proxy &
curl -s http://localhost:8001/api/v1/nodes/<node-name>/proxy/configz | python3 -m json.tool
```

The `configz` endpoint returns the full effective kubelet configuration as JSON. Check `cgroupDriver`, eviction thresholds, and authentication settings match your intended values.

Also check node conditions:
```bash
kubectl describe node <node-name> | grep -A5 Conditions
```

`MemoryPressure: False`, `DiskPressure: False`, `PIDPressure: False` — these confirm eviction is not active and the node is healthy.

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common kubelet config merge, configz, and node-condition failures.

---

### [8:15–9:15] Real World — Drift and Configuration Management

In production, kubelet configuration drift is a real operational risk. Without a systematic approach:

- Node A joined six months ago with `cgroupDriver: cgroupfs`.
- Node B joined last month with `cgroupDriver: systemd` after the standard was updated.
- Both are `Ready`. You do not notice until a pod on Node A behaves differently under memory pressure.

The fix is **configuration management as code**: every node is provisioned from the same base image, the same Ansible playbook, the same cloud-init script. The kubelet config file is part of that base configuration and is tested before it reaches production nodes.

Tools like **Kubelet Configuration Controller** (part of the Node Feature Discovery ecosystem) can report kubelet configuration drift as a Kubernetes event, making it visible in your observability stack.

---

### [9:15–10:00] Recap

- **kubelet** = node agent. Runs on every node. Translates API server instructions into runtime actions.
- **`/var/lib/kubelet/config.yaml`** = the KubeletConfiguration manifest. Managed by kubeadm, written by the apply script.
- **Critical fields**: `cgroupDriver` (must match runtime), eviction thresholds (protect nodes from OOM), authentication mode (secure the kubelet API).
- **Drain before applying** on live nodes — kubelet restart interrupts pod management briefly.
- **Verify with `configz`** — do not assume file writes produced the expected running configuration.

Next: 02.1.9 — Dual-stack Support with kubeadm, for clusters that need to serve both IPv4 and IPv6 traffic.

## Video close — fast validation

**What happens when you run this:**  
`systemctl is-active kubelet` on this host; `kubectl` reads first node’s conditions slice from describe — read-only except systemd query.

```bash
sudo systemctl is-active kubelet
kubectl get nodes -o wide
kubectl describe node "$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')" | sed -n '/Conditions:/,/Addresses:/p'
```
