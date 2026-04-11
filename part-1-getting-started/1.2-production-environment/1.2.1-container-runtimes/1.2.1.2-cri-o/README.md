# 1.2.1.2 CRI-O — teaching transcript

## Intro

**CRI-O** is built only for Kubernetes: CRI in, minimal surface out. Common on **RHEL / OpenShift** paths; versions track **Kubernetes minors** closely.

**You need:** a **Linux node** and **`sudo`**. Not a generic “laptop Minikube” lab unless you are deliberately configuring the node OS.

**Pick one runtime:** if you use **containerd** or **Docker + cri-dockerd**, skip this lesson — see [1.2.1](../README.md).

**Teaching tip:** Each step includes **What happens when you run this** before **Run**. `scripts/install-crio.sh` repeats the install story in a header comment at the top of the file.

## One-time setup — set your course directory

```bash
COURSE_DIR="$HOME/K8sOps"   # ← change this if you cloned elsewhere
```

---

## Step 1 — Open this lesson in the terminal

**What happens when you run this:**  
`cd`, `pwd`, `chmod +x scripts/*.sh` — navigate and mark scripts executable only.

**Say:**  
I move into the lesson folder so `./scripts` resolves, then make all scripts executable.

**Run:**

```bash
cd "$COURSE_DIR/part-1-getting-started/1.2-production-environment/1.2.1-container-runtimes/1.2.1.2-cri-o"
pwd
chmod +x scripts/*.sh
```

**Expected:**  
Path ends with `1.2.1.2-cri-o`.

---

## Step 2 — Install CRI-O (root, idempotent)

**What happens when you run this:**  
`sudo ./scripts/install-crio.sh` installs packages, writes `/etc/crio/crio.conf.d/02-cgroup-manager.conf`, enables/restarts `crio` — full sequence in the script header.

**Say:**  
Script installs CRI-O + runc, writes cgroup manager drop-in (`systemd`), enables and restarts **crio**.

**Run:**

```bash
sudo ./scripts/install-crio.sh
```

**Expected:**  
Script finishes cleanly; re-run does not break an existing install.

---

## Step 3 — Service is up

**What happens when you run this:**  
`systemctl is-active` / `status` query systemd for the `crio` unit — no config files changed.

**Run:**

```bash
sudo systemctl is-active crio
sudo systemctl status crio --no-pager
```

**Expected:**  
`active`; `crio` running.

---

## Step 4 — CRI socket exists

**What happens when you run this:**  
`ls -la` lists the CRI-O Unix socket — confirms path kubelet must use.

**Run:**

```bash
ls -la /var/run/crio/crio.sock
```

**Expected:**  
Socket present.

---

## Step 5 — CRI responds

**What happens when you run this:**  
`crictl ... info` hits the CRI-O endpoint and prints JSON; optional `grep` filters for cgroup-related fields — read-only.

**Run:**

```bash
sudo crictl --runtime-endpoint unix:///var/run/crio/crio.sock info
```

**Expected:**  
JSON; no connection error. Optional check:

```bash
sudo crictl --runtime-endpoint unix:///var/run/crio/crio.sock info | grep -i cgroup
```

**See:** cgroup driver consistent with **systemd** (per your cluster plan).

---

## Step 6 — Match kubeadm to this socket

**What happens when you run this:**  
`grep` shows the example `criSocket` line in the repo YAML — no cluster apply yet.

**Run:**

```bash
grep -n criSocket yamls/kubeadm-node-config-crio.yaml
```

**Expected:**  
`unix:///var/run/crio/crio.sock` (or equivalent in file).

---

## Step 7 — Fast recap

**What happens when you run this:**  
`systemctl status crio` + `crictl version` — final sanity check of service and CRI versions.

**Run:**

```bash
sudo systemctl status crio --no-pager
sudo crictl --runtime-endpoint unix:///var/run/crio/crio.sock version
```

**Expected:**  
Service OK; `crictl` version output succeeds.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/install-crio.sh` | Packages + cgroup drop-in + restart |
| `yamls/kubeadm-node-config-crio.yaml` | Example `criSocket` for CRI-O |
| `yamls/failure-troubleshooting.yaml` | Install / socket / cgroup hints |

---

## Troubleshooting

- **Package / repo errors** → match CRI-O major to your OS and target Kubernetes version (see CRI-O docs).
- **`crictl` connection failed** → `sudo journalctl -u crio -n 50`
- **cgroup driver mismatch** → confirm drop-in under `/etc/crio/crio.conf.d/` and kubelet `cgroupDriver: systemd`
- **Wrong socket in kubeadm** → must be CRI-O socket, not Docker’s

---

## Learning objective

- Install CRI-O, verify socket and `crictl`, point kubeadm config at the CRI-O endpoint.

## Why this matters

OpenShift-style and many enterprise clusters standardize on CRI-O; the skill transfers to vanilla kubeadm the same way.

## Next

[containerd](../1.2.1.1-containerd/README.md) or [Docker + cri-dockerd](../1.2.1.3-docker-engine-via-cri-dockerd/README.md) if you need another track; otherwise [1.2.2](../../1.2.2-installing-kubernetes-with-deployment-tools/README.md).
