# 1.2.1.2 CRI-O — teaching transcript

## Intro

**CRI-O** is built only for Kubernetes: CRI in, minimal surface out. Common on **RHEL / OpenShift** paths; versions track **Kubernetes minors** closely.

**You need:** a **Linux node** and **`sudo`**. Not a generic “laptop Minikube” lab unless you are deliberately configuring the node OS.

**Pick one runtime:** if you use **containerd** or **Docker + cri-dockerd**, skip this lesson — see [1.2.1](../README.md).

**Teaching tip:** Each step includes **What happens when you run this** before **Run**. `scripts/install-crio.sh` repeats the install story in a header comment at the top of the file.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/part-1-getting-started/1.2-production-environment/1.2.1-container-runtimes/1.2.1.2-cri-o"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  chmod scripts  →  sudo install   →  systemctl +    →  socket ls   →  crictl info  →  kubeadm YAML
                    CRI-O              status                          grep           recap
```

**Say:**

Same rhythm as containerd: executable scripts, root install, systemd proof, socket on disk, `crictl` proof, then the kubeadm snippet for the CRI-O endpoint.

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

**Say:**

CRI-O must be active before I trust `crictl` — otherwise every later failure is noise.

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

**Say:**

Final glance: `crio` still running, CRI versions print — kubelet will use this socket on join.

**Run:**

```bash
sudo systemctl status crio --no-pager
sudo crictl --runtime-endpoint unix:///var/run/crio/crio.sock version
```

**Expected:**  
Service OK; `crictl` version output succeeds.

---

## Troubleshooting

- **`Unable to locate package cri-o` or repo errors** → align CRI-O major with OS and target Kubernetes (see CRI-O project docs)
- **`crictl: rpc error: code = Unavailable`** → `sudo journalctl -u crio -n 50` for startup failures
- **`cgroup driver is cgroupfs` mismatches kubelet** → confirm `/etc/crio/crio.conf.d/` drop-ins and kubelet `cgroupDriver: systemd`
- **`wrong node /var/run/docker.sock` in kubelet args** → switch to `unix:///var/run/crio/crio.sock` in kubeadm config
- **Socket path differs on your distro** → `sudo crio-status` or distro package docs for the canonical path

---

## Learning objective

- Installed CRI-O, verified the socket and `crictl`, and pointed kubeadm’s `criSocket` at the CRI-O endpoint.

## Why this matters

OpenShift-style and many enterprise clusters standardize on CRI-O; the skill transfers to vanilla kubeadm the same way.

## Video close — fast validation

**What happens when you run this:**

Read-only: `systemctl is-active` and `crictl info` for CRI-O.

**Say:**

I match the module’s CRI-O closing block — active service, JSON from `crictl info`.

**Run:**

```bash
sudo systemctl is-active crio
sudo crictl --runtime-endpoint unix:///var/run/crio/crio.sock info >/dev/null && echo "crictl: OK"
```

**Expected:**

`active` then `crictl: OK`.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/install-crio.sh` | Packages + cgroup drop-in + restart |
| `yamls/kubeadm-node-config-crio.yaml` | Example `criSocket` for CRI-O |
| `yamls/failure-troubleshooting.yaml` | Install / socket / cgroup hints |

---

## Next

[containerd](../1.2.1.1-containerd/README.md) or [Docker + cri-dockerd](../1.2.1.3-docker-engine-via-cri-dockerd/README.md) if you need another track; otherwise [1.2.2](../../1.2.2-installing-kubernetes-with-deployment-tools/README.md).
