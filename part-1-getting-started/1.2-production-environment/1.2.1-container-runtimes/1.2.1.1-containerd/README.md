# 1.2.1.1 containerd — teaching transcript

## Intro

**containerd** is the usual production choice: CRI-native, used by major clouds, good default before `kubeadm init` / `join`.

**You need:** a **Linux node** (VM or bare metal) where you can use **`sudo`**. These steps are **not** for your Minikube laptop unless you know you are configuring node OS packages there.

**Pick one runtime:** if you use **CRI-O** or **Docker + cri-dockerd**, skip this lesson and open the matching sibling under [1.2.1](../README.md).

**Teaching tip:** Each step includes **What happens when you run this** before **Run**. `scripts/install-containerd.sh` repeats the install story in a header comment at the top of the file.

## One-time setup — set your course directory

```bash
COURSE_DIR="$HOME/K8sOps"   # ← change this if you cloned elsewhere
```

---

## Step 1 — Open this lesson in the terminal

**What happens when you run this:**  
`cd` into the lesson; `pwd` confirms; `chmod +x scripts/*.sh` makes install script runnable — no packages installed yet.

**Say:**  
I run install scripts from this folder so `./scripts` resolves.

**Run:**

```bash
cd "$COURSE_DIR/part-1-getting-started/1.2-production-environment/1.2.1-container-runtimes/1.2.1.1-containerd"
pwd
chmod +x scripts/*.sh
```

**Expected:**  
Path ends with `1.2.1.1-containerd`.

---

## Step 2 — Install containerd (root, idempotent)

**What happens when you run this:**  
`sudo ./scripts/install-containerd.sh` runs the script as root: `apt` install/patch config/enable systemd for containerd — see script header for the exact sequence.

**Say:**  
The script installs packages, generates or patches config (`SystemdCgroup = true`), and restarts **containerd**. Safe to run again on the same node.

**Run:**

```bash
sudo ./scripts/install-containerd.sh
```

**Expected:**  
Script completes without error; no duplicate-install explosions on re-run.

---

## Step 3 — Service is up

**What happens when you run this:**  
`systemctl is-active` prints `active` or not; `systemctl status` shows unit state and recent log lines — read-only aside from systemd’s status query.

**Run:**

```bash
sudo systemctl is-active containerd
sudo systemctl status containerd --no-pager
```

**Expected:**  
`active`; status shows running (no fatal errors in last lines).

---

## Step 4 — CRI socket exists

**What happens when you run this:**  
`ls -la` shows the Unix socket file metadata — confirms containerd is listening on the expected path.

**Say:**  
kubelet will dial this socket. Wrong path = node never becomes Ready later.

**Run:**

```bash
ls -la /run/containerd/containerd.sock
```

**Expected:**  
Socket file present.

---

## Step 5 — CRI responds

**What happens when you run this:**  
`crictl ... info` calls the CRI over the socket and prints JSON runtime info — proves the API answers; does not start a workload.

**Run:**

```bash
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock info
```

**Expected:**  
JSON with healthy runtime info (no “connection refused”).

---

## Step 6 — Match kubeadm to this socket

**What happens when you run this:**  
`grep` searches the example YAML for `criSocket` lines — read-only; shows what you’ll pass to kubeadm later.

**Say:**  
When you bootstrap with kubeadm, node registration must use the **same** socket. This repo ships an example manifest.

**Run:**

```bash
grep -n criSocket yamls/kubeadm-node-config-containerd.yaml
```

**Expected:**  
Line showing `unix:///run/containerd/containerd.sock` (or equivalent).

---

## Step 7 — Fast recap

**What happens when you run this:**  
`systemctl status` again for sanity; `crictl version` prints client/server CRI versions — still verification only.

**Run:**

```bash
sudo systemctl status containerd --no-pager
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock version
```

**Expected:**  
Service OK; `crictl` prints client/server versions.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/install-containerd.sh` | Install + configure `SystemdCgroup` + restart |
| `yamls/kubeadm-node-config-containerd.yaml` | Example `criSocket` for kubeadm |
| `yamls/failure-troubleshooting.yaml` | Socket / cgroup / install hints |

---

## Troubleshooting

- **Not root** → install script must run under `sudo`
- **cgroup errors later with kubelet** → confirm `SystemdCgroup = true` in containerd config and kubelet uses `cgroupDriver: systemd`
- **`crictl` fails** → `sudo journalctl -u containerd -n 50`
- **Socket missing** → service not started or wrong path for your distro (check lesson + distro docs)

---

## Learning objective

- Install containerd, verify socket and `crictl`, align kubeadm config with the CRI endpoint.

## Why this matters

Wrong runtime or cgroup mismatch is a top reason fresh kubeadm nodes stay **NotReady**.

## Next

[CRI-O](../1.2.1.2-cri-o/README.md) (alternative) or [Docker + cri-dockerd](../1.2.1.3-docker-engine-via-cri-dockerd/README.md) (legacy), then [1.2.2 Installing Kubernetes with deployment tools](../../1.2.2-installing-kubernetes-with-deployment-tools/README.md) when your course path says so.
