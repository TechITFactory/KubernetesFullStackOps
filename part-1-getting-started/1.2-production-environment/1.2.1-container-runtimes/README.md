# 1.2.1 Container Runtimes

## Intro

Kubernetes does **not** run containers itself. Each node runs a **CRI-compatible runtime** (Container Runtime Interface). kubelet talks to the runtime through a **Unix socket**; cgroup settings must match **systemd** on modern Linux.

**Pick one runtime per node.** Lessons **1.2.1.1**, **1.2.1.2**, and **1.2.1.3** are **alternatives** — same teaching layout (**What happens → Say → Run → Expected**), different packages and sockets.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/part-1-getting-started/1.2-production-environment/1.2.1-container-runtimes"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  Pick exactly one runtime per node
              │
    ┌─────────┼─────────┐
    ▼         ▼         ▼
 1.2.1.1   1.2.1.2   1.2.1.3
containerd   CRI-O    Docker + cri-dockerd
    │         │         │
    └─────────┴─────────┘
              ▼
     Verify service + crictl
     (equal checks for each)
```

**Say:**

You choose **one** lesson under this folder for each Linux node. After install, every path ends the same way: systemd says the daemon is active and `crictl info` succeeds against that runtime’s socket.

---

## Step 1 — Open this module folder

**What happens when you run this:**

`cd` moves into `1.2.1-container-runtimes`. `pwd` prints the path.

**Say:**

I stand here so links to **1.2.1.1**–**1.2.1.3** resolve the same way on camera.

**Run:**

```bash
cd "$COURSE_DIR/part-1-getting-started/1.2-production-environment/1.2.1-container-runtimes"
pwd
```

**Expected:**

Path ending with `1.2.1-container-runtimes`.

---

## Step 2 — Open exactly one runtime lesson (reading step)

**What happens when you run this:**

You open **one** child README and follow its steps on a Linux node with `sudo`.

**Say:**

I match the lesson to the OS and support policy for my cluster. I do **not** install two runtimes for the same kubelet without a migration plan.

**Run:**

_(Open one link from the table below.)_

**Expected:**

You are reading [containerd](1.2.1.1-containerd/README.md), [CRI-O](1.2.1.2-cri-o/README.md), or [Docker + cri-dockerd](1.2.1.3-docker-engine-via-cri-dockerd/README.md).

---

## Troubleshooting

- **`crictl: cannot connect to the endpoint`** → confirm you passed the **correct** socket for the runtime you installed; compare with the lesson’s `grep criSocket` YAML
- **`inactive` from `systemctl is-active`** → `sudo systemctl status <unit>` and journal logs for the daemon named in that lesson
- **Mixed instructions from multiple 1.2.1.x lessons** → pick one runtime; uninstall or reset the node before switching in a real cluster
- **`permission denied` on `/run/...sock`** → use `sudo` with `crictl` or add your user only per your organization’s policy (production nodes usually stay root-only for CRI)
- **kubelet still `NotReady` after green `crictl`** → continue to CNI and kubeadm lessons — runtime was necessary but not sufficient

---

## Learning objective

- Chose one supported runtime path per node and located the matching lesson.
- Repeated the same validation pattern: service active, `crictl info` clean.
- Explained why kubelet targets the CRI socket rather than the Docker API socket.

## Why this matters

Wrong runtime choice or cgroup mismatch is a top reason fresh nodes stay **NotReady** after `kubeadm join`. Validating each stack the same way catches mistakes before you burn time on the control plane.

## Video close — fast validation

**What happens when you run this:**

`systemctl is-active` reports whether the runtime daemon is running. `crictl info` calls the CRI API over the Unix socket — both are read-only. Run **one** block — the block for the runtime you installed.

**Say:**

I treat the three runtimes equally in the closing shot: same shape of commands, different unit names and sockets. Pick the block you actually installed.

**Run — containerd (1.2.1.1):**

```bash
sudo systemctl is-active containerd
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock info
```

**Run — CRI-O (1.2.1.2):**

```bash
sudo systemctl is-active crio
sudo crictl --runtime-endpoint unix:///var/run/crio/crio.sock info
```

**Run — Docker + cri-dockerd (1.2.1.3):**

```bash
sudo systemctl is-active docker
sudo systemctl is-active cri-docker
sudo crictl --runtime-endpoint unix:///run/cri-dockerd.sock info
```

**Expected for all three:** service reports `active`, `crictl info` returns JSON with no "connection refused" error.

Before **1.2.2 (kubeadm)**, you want both checks green. A missing socket or `inactive` daemon is why a fresh node stays `NotReady` after join.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `1.2.1.1-containerd/README.md` | containerd install + socket |
| `1.2.1.2-cri-o/README.md` | CRI-O install + socket |
| `1.2.1.3-docker-engine-via-cri-dockerd/README.md` | Docker + shim install + socket |

---

| Lesson | Link | When to choose |
|--------|------|----------------|
| **1.2.1.1** | [containerd](1.2.1.1-containerd/README.md) | Default for new clusters; kubeadm / cloud-style paths. |
| **1.2.1.2** | [CRI-O](1.2.1.2-cri-o/README.md) | OpenShift / RHEL-style; tight K8s version alignment. |
| **1.2.1.3** | [Docker + cri-dockerd](1.2.1.3-docker-engine-via-cri-dockerd/README.md) | Legacy / migration only — not for greenfield. |

---

## Next

When nodes validate, continue with [1.2.2 Installing Kubernetes with deployment tools](../1.2.2-installing-kubernetes-with-deployment-tools/README.md).
