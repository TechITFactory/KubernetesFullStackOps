# 1.2.2.1.1 Installing kubeadm

- **Summary**: Install `kubeadm`, `kubelet`, and `kubectl` from the official Kubernetes package repository, pinned to a specific minor version.
- **Content**: What each binary does, the `pkgs.k8s.io` repo model, version pinning with `apt-mark hold`, idempotent install automation.
- **Lab**: Run `install-kubeadm.sh` as root on all candidate nodes, confirm versions, verify kubelet is enabled.

## Files

| Path | Purpose |
|------|---------|
| `scripts/install-kubeadm.sh` | Idempotent: adds the Kubernetes APT repo, installs and holds kubeadm + kubelet + kubectl |
| `yamls/repo-version-plan.yaml` | Reference doc — maps Kubernetes minor versions to repo URLs and package holds |

**Teaching tip:** Use **What happens when you run this** before each runnable block so you can teach without discovering side effects live. The same steps are documented in **WHAT THIS DOES WHEN YOU RUN IT** at the top of `scripts/install-kubeadm.sh`.

## Quick Start

**What happens when you run this:**  
- `sudo ... install-kubeadm.sh` — as root, adds the Kubernetes apt repo for `K8S_MINOR_VERSION`, installs `kubelet`/`kubeadm`/`kubectl`, runs `apt-mark hold` on those packages, enables kubelet (it may not stay healthy until after `kubeadm init`/`join` — expected).  
- The three `version` commands — print client/binary versions only; no cluster changes.

```bash
# Run as root on every node (control-plane and workers)
sudo K8S_MINOR_VERSION=v1.31 ./scripts/install-kubeadm.sh

# Verify
kubeadm version
kubelet --version
kubectl version --client
```

---

## Transcript — 10-Minute Lesson

### [0:00–0:45] Hook

You have a container runtime running. Now you need the three binaries that turn a Linux server into a Kubernetes node.

Three tools. Three different jobs. All installed together, all version-pinned to the same minor release. This lesson covers exactly what each does and why getting this right — especially the version pinning — matters so much in production.

---

### [0:45–2:30] Three Binaries, Three Jobs

**`kubelet`** — the node agent. Runs on every node — control plane and workers alike. It is a long-running daemon that talks to the API server, receives pod specifications, and tells the container runtime to start or stop containers. Think of kubelet as the foreman on a construction site: it receives the blueprints from headquarters (the API server) and coordinates the actual workers (the runtime) on the ground.

**`kubectl`** — the CLI client. A command-line tool you use from your laptop or the control-plane node to talk to the Kubernetes API. `kubectl get pods`, `kubectl apply`, `kubectl logs` — all of this is kubectl. It does not run as a daemon; it is just a binary you invoke.

**`kubeadm`** — the bootstrapper. Used once (or a handful of times) to initialise the cluster, generate certificates, and join nodes. Once the cluster is running, you rarely touch kubeadm until upgrade time. Think of it as the scaffolding that assembles the building — essential during construction, not needed once it is standing.

All three must be installed on **every node**, including workers (workers need kubelet; kubeadm and kubectl are installed for convenience but only actively used on control-plane nodes).

---

### [2:30–4:00] The Package Repository Model

Kubernetes does not ship packages through the standard Ubuntu/Debian repositories. It uses its own apt repository hosted at `pkgs.k8s.io`.

The repository is organised by Kubernetes **minor version**:

```
https://pkgs.k8s.io/core:/stable:/v1.31/deb/
https://pkgs.k8s.io/core:/stable:/v1.32/deb/
```

Each minor version has its own repo URL. This means:
- You explicitly choose which minor version you install.
- Upgrading to a new minor version means pointing at a new repo URL.
- Patch releases (v1.31.1, v1.31.2, ...) are in the same repo and upgrade automatically unless you pin.

The install script handles the repo setup:

```bash
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S_MINOR_VERSION}/deb/Release.key" | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=...] https://pkgs.k8s.io/core:/stable:/${K8S_MINOR_VERSION}/deb/ /" > /etc/apt/sources.list.d/kubernetes.list
```

The GPG key is fetched and stored first — this ensures package authenticity. The repo line is then written, referencing that key.

---

### [4:00–5:30] Version Pinning — Why It Is Critical

After installing, the script runs:

```bash
apt-mark hold kubelet kubeadm kubectl
```

`apt-mark hold` tells apt: do not upgrade these packages automatically, even when `apt upgrade` is run.

Why does this matter? **Kubernetes must be upgraded in order, one minor version at a time.** You cannot jump from 1.28 to 1.31. The upgrade path is: 1.28 → 1.29 → 1.30 → 1.31.

If `apt upgrade` ran unattended and bumped kubeadm from 1.30 to 1.31 on your control plane overnight — while workers are still on 1.30 — your cluster is in an inconsistent state. Control plane components at one version, worker kubelet at another. This is a support nightmare.

`apt-mark hold` prevents this. Upgrades are a deliberate, manual process. When you are ready to upgrade, you release the hold, upgrade, re-apply the hold, and move on.

**Real production rule**: never run `apt upgrade` without checking what Kubernetes packages are held first.

---

### [5:30–7:00] The Install Script — Line by Line

```bash
K8S_MINOR_VERSION="${K8S_MINOR_VERSION:-v1.35}"
```
Defaults to a pinned version but is easily overridden: `K8S_MINOR_VERSION=v1.31 ./install-kubeadm.sh`. This makes the script reusable across cluster generations without editing.

```bash
if [[ ! -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]]; then
  curl -fsSL ... | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
fi
```
Idempotent key import — only downloads if the keyring file does not exist. Safe to re-run.

```bash
if [[ ! -f "$REPO_FILE" ]] || ! grep -Fqx "$REPO_LINE" "$REPO_FILE"; then
  echo "$REPO_LINE" > "$REPO_FILE"
fi
```
Idempotent repo setup — only writes if the file is missing or the repo line is not already there.

```bash
for pkg in kubelet kubeadm kubectl; do
  if ! package_installed "$pkg"; then
    apt-get install -y "$pkg"
  else
    echo "$pkg already installed. Skipping."
  fi
done
```
Per-package idempotency — each package is checked independently.

```bash
apt-mark hold kubelet kubeadm kubectl
systemctl enable --now kubelet || true
```
Hold applied after install. `|| true` on kubelet enable — kubelet will fail to start without a kubeadm config, and that is expected at this stage.

---

### [7:00–8:15] What "kubelet enabled but not running" Means

After install, kubelet is enabled but will fail to start:

```bash
systemctl status kubelet
# Active: activating (auto-restart)
```

This is normal. kubelet needs a cluster configuration to know which API server to talk to, where to find the runtime socket, and what cgroup settings to use. kubeadm provides that configuration during `kubeadm init` or `kubeadm join`. Until then, kubelet loops in a start-fail-restart cycle.

Do not troubleshoot this exit code — it is expected. If kubelet is in this state after a successful `kubeadm init` or `kubeadm join`, then something else is wrong.

---

### [8:15–9:30] Real World — Package Management at Scale

In real production environments, you rarely run `install-kubeadm.sh` by hand on individual nodes. You use a configuration management tool:

- **Ansible**: a playbook runs the equivalent of this script across all nodes simultaneously.
- **Terraform + cloud-init**: nodes boot with a cloud-init script that installs the packages on first start.
- **Packer**: a base image is baked with kubeadm pre-installed; nodes boot from that image.

In all cases the underlying logic is the same: add the repo, install the packages, hold the versions. The script here teaches you what is happening inside those higher-level tools.

At companies running hundreds of nodes, **version drift** is a real operational risk. Tooling like `kubectl get nodes -o wide` shows kubelet versions per node, making drift visible. Automated checks alert on-call when nodes are more than one patch version behind the control plane.

---

### [9:30–10:00] Recap

- **`kubelet`** = node agent (daemon). Runs on every node. Talks to API server, drives the runtime.
- **`kubectl`** = CLI client. Used from laptop or control-plane node. Not a daemon.
- **`kubeadm`** = bootstrapper. Used for init, join, and upgrade. Not a daemon.
- **`pkgs.k8s.io`** — the official Kubernetes package repo, versioned by minor release.
- **`apt-mark hold`** — version pins. Non-negotiable in production. Prevents uncontrolled upgrades.
- Script is **idempotent** — keyring, repo, and each package are checked before acting.

Next: 1.2.2.1.2 — Troubleshooting kubeadm, covering diagnostic collection before you touch a failing node.

## Video close — fast validation

**What happens when you run this:**  
Re-runs the same three version prints — quick proof the binaries are on PATH after the lesson.

```bash
kubeadm version
kubelet --version
kubectl version --client
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common kubeadm package/repo/version-hold failures and fixes.
