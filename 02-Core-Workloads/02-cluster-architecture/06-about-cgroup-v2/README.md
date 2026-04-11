# 2.2.6 About cgroup v2 â€” teaching transcript

## Intro

**cgroups** (control groups) are a Linux kernel feature that limits and isolates resource usage â€” CPU, memory, disk I/O â€” for groups of processes. Kubernetes uses cgroups to enforce the resource requests and limits you set on containers.

**cgroup v2** is the unified hierarchy. Instead of separate controllers mounted at different paths (the v1 model), all resource controllers live under a single `/sys/fs/cgroup` hierarchy. Most modern Linux distributions (Ubuntu 22.04+, Fedora 31+, Debian 11+) default to cgroup v2.

The critical requirement: **kubelet and the container runtime must use the same cgroup driver** â€” either `cgroupfs` or `systemd`. A mismatch causes the kubelet to fail at startup or behave unpredictably. On systemd-based distributions, `systemd` is the correct driver for both. Checking this alignment is part of node validation before joining a cluster.

> **Note on where to run:** `check-cgroup-version.sh` reads `/sys/fs/cgroup` on the **local machine**. If you are running `kubectl` from a laptop that is not a cluster node, SSH into a node first to get accurate results.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

---

## Flow of this lesson

```
  [ Step 1 ]                    [ Step 2 ]
  Run local cgroup     â†’        Check kubelet and runtime
  version detection             versions on nodes via kubectl
  script
```

**Say:** "Two steps. First we detect the cgroup version on the local machine â€” or on a node if you SSH first. Then we use kubectl to check the runtime and kubelet versions visible from the API server, so we can confirm what the cluster is actually running."

---

## Step 1 â€” Detect cgroup version

**What happens when you run this:**
`check-cgroup-version.sh` reads `/sys/fs/cgroup` to determine whether the host is running cgroup v1 or v2. The `kubectl` commands then show node runtime and kubelet version strings from the API server perspective. All read-only.

**Say:** "The script reads the filesystem type of /sys/fs/cgroup. If it shows `cgroup2fs`, the host is on cgroup v2. If it shows `tmpfs`, it's on v1. After the script, I look at the nodes to see their container runtime version â€” that tells me which CRI is running, which must be configured with the same cgroup driver as kubelet."

**Run:**

```bash
chmod +x scripts/*.sh
./scripts/check-cgroup-version.sh
kubectl get nodes -o wide
kubectl describe node "$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')" \
  | grep -i -E 'container runtime|kubelet version' || true
```

**Expected:**
Script prints `cgroup v2 detected` or `cgroup v1 detected`. Node describe shows `Container Runtime Version` and `Kubelet Version` lines.

---

## Step 2 â€” Verify with stat

**What happens when you run this:**
`stat -fc %T /sys/fs/cgroup` prints the filesystem type of the cgroup mount directly. `cgroup2fs` = v2, `tmpfs` = v1. This is the same check the script does, shown explicitly.

**Say:** "This one-liner is faster than the script if you just need a quick answer. On a node running Ubuntu 22.04 or newer, you should see cgroup2fs. If you see tmpfs and your cluster is using systemd as the cgroup driver, there's a configuration mismatch to fix before joining or upgrading nodes."

**Run:**

```bash
stat -fc %T /sys/fs/cgroup
```

**Expected:**
`cgroup2fs` (cgroup v2) or `tmpfs` (cgroup v1).

---

## Troubleshooting

- **`kubelet fails to start with cgroup driver mismatch`** â†’ check `/var/lib/kubelet/config.yaml` for `cgroupDriver` and compare it to the runtime's cgroup driver; for containerd, check `/etc/containerd/config.toml` under `[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]` for `SystemdCgroup = true`; both must match.
- **`Node NotReady after upgrade`** â†’ a distro upgrade may have switched from cgroup v1 to v2; if kubelet was configured for cgroupfs and the new kernel uses cgroup v2 with systemd, update `cgroupDriver: systemd` in the kubelet config and restart.
- **`Container OOMKilled immediately despite limits`** â†’ on cgroup v1, memory limits are per-controller; on v2, limits are unified; a container with a very low memory limit that worked on v1 may OOMKill faster on v2; review actual memory usage first.
- **`stat: cannot stat '/sys/fs/cgroup'`** â†’ running inside a container without the cgroup filesystem mounted; run on the host or SSH to a node to check.

---

## Learning objective

- Explain the difference between cgroup v1 and cgroup v2.
- Identify the cgroup version on a node using `stat -fc %T /sys/fs/cgroup`.
- State the consequence of a kubelet/runtime cgroup driver mismatch.

## Why this matters

cgroup driver mismatches are one of the most common reasons `kubeadm join` fails or nodes go `NotReady` after an OS upgrade. Knowing how to detect the cgroup version and verify driver alignment is a practical node troubleshooting skill used during cluster setup, node replacement, and OS upgrades.

---

## Video close â€” fast validation

**What happens when you run this:**
Direct cgroup version check; nodes wide; recent events. All read-only.

**Say:** "stat, nodes, events â€” three-second health check. cgroup2fs means v2, nodes Ready, no recent pressure events â€” the node resource isolation layer is healthy."

```bash
stat -fc %T /sys/fs/cgroup
kubectl get nodes -o wide
kubectl get events -A --sort-by=.lastTimestamp | tail -n 20
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/check-cgroup-version.sh` | Local cgroup version detection |
| `yamls/cgroup-v2-notes.yaml` | Reference notes ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Driver mismatch and OOM hints |

---

## Next

[2.2.7 Kubernetes self-healing](../07-kubernetes-self-healing/README.md)
