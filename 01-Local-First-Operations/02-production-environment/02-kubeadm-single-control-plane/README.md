# 02.03 Creating a Cluster with kubeadm

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/02-production-environment/02-kubeadm-single-control-plane"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  init control plane  â†’  install CNI  â†’  verify Ready  â†’  print join  â†’  join workers
```

**Say:**

The cluster becomes real on `kubeadm init`, but nodes stay tainted until a CNI runs; only then do I hand out join commands for workers.

---

- **Summary**: Initialise the Kubernetes control plane from a config file, copy the admin kubeconfig, and generate a reproducible worker join command.
- **Content**: What `kubeadm init` does step by step, the admin.conf file, CNI requirement, bootstrap token join mechanics, idempotent init script.
- **Lab**: Run `init-control-plane.sh` as root, install a CNI plugin, run `print-worker-join-command.sh`, join a worker node.

## Files

| Path | Purpose |
|------|---------|
| `scripts/init-control-plane.sh` | Idempotent: runs `kubeadm init` from config only if not already initialised, copies kubeconfig |
| `scripts/print-worker-join-command.sh` | Generates a fresh join token and prints the full `kubeadm join` command |
| `yamls/kubeadm-init-config.yaml` | Config-driven cluster initialisation â€” control-plane endpoint, pod CIDR, CRI socket |

**Teaching tip:** **What happens when you run this** below matches **WHAT THIS DOES WHEN YOU RUN IT** in `scripts/init-control-plane.sh` and `scripts/print-worker-join-command.sh`.

## Quick Start

**What happens when you run this:**  
1. `init-control-plane.sh` â€” if no `/etc/kubernetes/admin.conf`, runs `kubeadm init --config`; copies admin kubeconfig to `~/.kube/config`; `kubectl get nodes` (expect **NotReady** until CNI).  
2. `kubectl apply` Flannel â€” installs CNI DaemonSet/ConfigMap; nodes should become **Ready** once CNI pods run.  
3. `kubectl get nodes` â€” read-only cluster state.  
4. `print-worker-join-command.sh` â€” creates a bootstrap token and prints full `kubeadm join ...` (run that on workers as root).  
5. On workers â€” `kubeadm join` registers the node; no output here (you paste the printed command).

```bash
# 1. Initialise control plane (run as root on control-plane node)
sudo ./scripts/init-control-plane.sh

# 2. Install a CNI (example: Flannel)
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# 3. Verify nodes are Ready
kubectl get nodes

# 4. Generate join command (run as root on control-plane node)
sudo ./scripts/print-worker-join-command.sh

# 5. Run the output command on each worker node (as root)
```

---

## Transcript â€” 10-Minute Lesson

### [0:00â€“0:45] Hook

Everything up to this point has been preparation â€” installing a runtime, installing kubeadm packages. This is the lesson where the cluster actually comes to life.

`kubeadm init` is the single command that goes from "a Linux server with some packages installed" to "a functioning Kubernetes control plane." It generates certificates, starts the API server, configures etcd, and produces everything a worker node needs to join.

By the end of this lesson you will have a working cluster with at least one control-plane node and one worker.

---

### [0:45â€“2:30] What `kubeadm init` Does Internally

When you run `kubeadm init`, it executes these steps in order:

1. **Preflight checks** â€” verifies swap is off, runtime is running, ports are free, kernel modules loaded. Fails here if anything is wrong (see 02.1.2 for how to diagnose).

2. **Certificate generation** â€” creates a Certificate Authority (CA), then issues certificates for the API server, etcd, kubelet, and front-proxy. All stored in `/etc/kubernetes/pki/`.

3. **kubeconfig generation** â€” creates `admin.conf`, `controller-manager.conf`, `scheduler.conf` in `/etc/kubernetes/`. These are how each component authenticates with the API server.

4. **Static pod manifests** â€” writes YAML files to `/etc/kubernetes/manifests/`. kubelet watches this directory and starts the API server, controller-manager, scheduler, and etcd as **static pods** â€” pods managed by kubelet directly, not by Kubernetes itself.

5. **Wait for control plane** â€” polls the API server until it is healthy.

6. **Bootstrap token and RBAC** â€” creates a bootstrap token that worker nodes use to authenticate during join, and sets up the RBAC rules for that token.

7. **CNI placeholder** â€” sets `node.kubernetes.io/not-ready:NoSchedule` taint on the control-plane node, waiting for a CNI plugin to install.

8. **Join command printed** â€” the final output is the `kubeadm join` command workers need.

---

### [2:30â€“3:45] The Config File â€” Why Not Flags

The script uses:
```bash
kubeadm init --config "$CONFIG_PATH"
```
Not:
```bash
kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.010 ...
```

Config files are better for production because:
- They live in version control â€” your cluster configuration is documented and reviewable.
- They are reproducible â€” the same file produces the same cluster every time.
- They are complete â€” flags you forget to pass get their defaults silently; a config file makes all settings explicit.

`kubeadm-init-config.yaml` specifies the pod CIDR, the control-plane endpoint, and the CRI socket. These three values must be correct before init.

---

### [3:45â€“5:00] Idempotency in init-control-plane.sh

```bash
if [[ -f /etc/kubernetes/admin.conf ]]; then
  echo "A kubeadm control plane already appears initialized. Skipping."
else
  kubeadm init --config "$CONFIG_PATH"
fi
```

The presence of `/etc/kubernetes/admin.conf` is the definitive signal that a control plane has already been initialised on this node. Running `kubeadm init` twice on the same node causes errors â€” it would try to recreate certificates and static pods that already exist.

The idempotency check makes the script safe to run twice â€” on a re-run, it skips init and proceeds to copy the kubeconfig.

```bash
mkdir -p "$HOME/.kube"
cp -f /etc/kubernetes/admin.conf "$HOME/.kube/config"
chown "$(id -u):$(id -g)" "$HOME/.kube/config"
```

Copies `admin.conf` to the standard kubectl location. The `admin.conf` file grants full cluster-admin access â€” treat it like a root password.

---

### [5:00â€“6:15] Why Nodes Are NotReady Without a CNI

After `kubeadm init`, run `kubectl get nodes`:

```
NAME           STATUS     ROLES           AGE
control-plane  NotReady   control-plane   2m
```

`NotReady` â€” even the control plane. This is not a failure. It is expected.

Kubernetes requires a **CNI (Container Network Interface)** plugin to set up pod networking. Until a CNI is installed, pods cannot communicate across nodes, and kubelet reports the node as not ready.

Popular CNI choices:

| CNI | Best for |
|-----|---------|
| Flannel | Simplicity â€” basic overlay networking |
| Calico | NetworkPolicy enforcement, BGP routing |
| Cilium | eBPF-based, observability, service mesh features |
| Weave | Easy setup, automatic key rotation |

Install one (e.g., Flannel):
```bash
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

Within 30 seconds, the node transitions to `Ready`. The taint is removed. Workloads can be scheduled.

---

### [6:15â€“7:15] Joining Worker Nodes

`print-worker-join-command.sh` runs:

```bash
kubeadm token create --print-join-command
```

This generates a new bootstrap token and prints the full join command:

```
kubeadm join 192.168.010:6443 --token abcdef.0123456789abcdef \
  --discovery-token-ca-cert-hash sha256:abc123...
```

Run this on each worker node (as root, after installing the runtime and kubeadm packages). The worker:
1. Uses the bootstrap token to authenticate with the API server.
2. Downloads cluster configuration and CA certificate, verifying it against the hash.
3. Starts kubelet configured to talk to the API server.
4. Appears in `kubectl get nodes` as `Ready` once the CNI assigns it networking.

Tokens expire after 24 hours by default. Run `print-worker-join-command.sh` again to generate a fresh token for new nodes.

---

### [7:15â€“8:30] Real World â€” How This Looks in Production

Production clusters are not initialised by hand. The typical pattern:

1. A **Terraform** or **Packer** base image has kubeadm, kubelet, kubectl, and the container runtime pre-installed.
2. The control-plane node boots from that image. An **Ansible playbook** or **cloud-init** script runs `kubeadm init --config /etc/kubeadm/init-config.yaml`.
3. The join command is written to a secure location (SSM Parameter Store, Vault, or a ConfigMap in a bootstrap cluster).
4. Worker nodes boot from the same base image. cloud-init reads the join command from the secure store and runs it automatically.

The same logic as `init-control-plane.sh` â€” check for `admin.conf` before running init â€” appears in Ansible tasks as `when: not admin_conf.stat.exists`. Idempotency is not just a script concern; it is a first-class property of all infrastructure automation.

---

### [8:30â€“9:30] Verifying the Cluster

After workers join and the CNI is installed:

```bash
# All nodes Ready
kubectl get nodes -o wide

# Control-plane components healthy
kubectl get pods -n kube-system

# API server, scheduler, controller-manager are running
kubectl get componentstatuses
```

Expected output:
```
NAME           STATUS   ROLES           AGE
control-plane  Ready    control-plane   10m
worker-1       Ready    <none>          5m
```

All pods in `kube-system` should be `Running`. `coredns` pods may be `Pending` briefly until the CNI is ready â€” that is normal.

---

### [9:30â€“10:00] Recap

- **`kubeadm init`** â€” generates PKI, starts control-plane components as static pods, creates bootstrap tokens.
- **Config file over flags** â€” reproducible, version-controllable, explicit.
- **`admin.conf`** â€” the cluster master key. Protect it. The idempotency check looks for this file.
- **CNI is required** â€” nodes are `NotReady` until a CNI plugin sets up pod networking.
- **`print-worker-join-command.sh`** â€” generates a fresh bootstrap token and prints the complete join command. Tokens expire in 24h.

Next: 02 â€” Customizing Components with the kubeadm API, where we explore everything you can control through the init config file.

## Video close â€” fast validation

**What happens when you run this:**  
Three read-only `kubectl` queries: node list with IPs, `kube-system` pods, cluster-info endpoint summary.

```bash
kubectl get nodes -o wide
kubectl get pods -n kube-system -o wide
kubectl cluster-info
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common `kubeadm init`, CNI readiness, and worker join issues.
