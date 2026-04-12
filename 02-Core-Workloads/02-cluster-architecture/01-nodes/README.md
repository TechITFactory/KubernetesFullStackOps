# Nodes — teaching transcript

## Intro

A node is a worker machine — physical or virtual — that runs your workloads. Every node runs three things: **kubelet** (the agent that takes pod assignments from the API server and ensures containers are running), **kube-proxy** (maintains network rules for Service routing), and a **container runtime** (containerd, CRI-O, or cri-dockerd).

The API server tracks two resource numbers per node: **capacity** (total CPU and memory on the machine) and **allocatable** (what's left after reserving for the OS and Kubernetes system processes). Pods are only scheduled against allocatable. If allocatable is near zero, new pods stay `Pending` even though the node looks healthy.

Nodes also report **conditions**: `Ready`, `MemoryPressure`, `DiskPressure`, `PIDPressure`, and `NetworkUnavailable`. `Ready=True` is the only condition that allows pod scheduling. Any pressure condition showing `True` triggers the eviction manager.

**Prerequisites:** [Part 1](../../../01-Local-First-Operations/README.md).

---

## Flow of this lesson

```
  [ Step 1 ]              [ Step 2 ]
  Run inspection  →       Describe first node
  script                  (capacity, allocatable,
  (wide node view)         conditions, runtime)
```

**Say:** "Two steps. First we get a wide view of all nodes — status, roles, ages, kernel and runtime versions. Then we describe one node in detail to see its capacity, allocatable resources, and current conditions."

---

## Step 1 — Inspect all nodes

**What happens when you run this:**
`inspect-nodes.sh` runs `kubectl get nodes -o wide`, showing all nodes with status, roles, Kubernetes version, container runtime, and internal IP. All read-only.

**Say:** "The ROLES column tells you which nodes are control-plane and which are workers. VERSION shows the kubelet version — this matters during upgrades because kubelet can lag the API server by up to two minor versions. CONTAINER-RUNTIME confirms which CRI is running on each node."

**Run:**

```bash
chmod +x scripts/*.sh
./scripts/inspect-nodes.sh
kubectl get nodes -o wide
```

**Expected:**
All nodes listed with `Ready` status. ROLES shows `control-plane` for at least one node. CONTAINER-RUNTIME shows `containerd://`, `cri-o://`, or similar.

---

## Step 2 — Describe a node in detail

**What happens when you run this:**
`kubectl describe node` on the first node (selected by jsonpath) prints the full node spec: labels, annotations, capacity, allocatable, conditions, system info, and running pods. `sed` limits output to the first 80 lines to keep the terminal readable.

**Say:** "Three things to read in describe output. First, the Conditions table — Ready should be True, all four pressure conditions should be False. Second, the Capacity and Allocatable block — if allocatable is much lower than capacity, a large system reservation is set. Third, the Non-terminated Pods section shows every pod on this node and its resource requests — that's how you find which pod is consuming the allocatable budget."

**Run:**

```bash
kubectl describe node "$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')" | sed -n '1,80p'
```

**Expected:**
`Conditions` block shows `Ready True`. `Capacity` and `Allocatable` blocks present. No pressure condition showing `True`.

---

## Troubleshooting

- **`NotReady` status on a node** → SSH to the node and run `systemctl status kubelet`; common causes are kubelet crashed, certificate expired, or container runtime not responding; check `journalctl -u kubelet -n 50` for the specific error.
- **`MemoryPressure=True`** → the node is low on memory; the eviction manager will start terminating pods; check `kubectl describe node <name>` for pods without memory limits consuming unbounded resources.
- **`DiskPressure=True`** → node disk usage is above the eviction threshold; check `df -h` on the node; stale container images are common — `crictl rmi --prune` frees space without affecting running containers.
- **`Unknown` condition** → the API server has not received a heartbeat in over 40 seconds; the node may be unreachable, the kubelet may have crashed, or there is a network partition between the node and the API server.
- **Pods stuck `Pending` despite available nodes** → check `kubectl describe pod <name>` for the scheduler message; `Insufficient cpu` or `Insufficient memory` means allocatable is exhausted; a taint mismatch shows as `node(s) had untolerated taint`.

---

## Learning objective

- List the three components running on every node (kubelet, kube-proxy, container runtime).
- Explain the difference between capacity and allocatable.
- Read node conditions from `kubectl describe node` and identify which indicate a problem.

## Why this matters

Node conditions are the first thing to check when pods won't schedule or are being evicted. A node showing `Ready=True` is not the same as a node with scheduling headroom — allocatable tells you whether pods can actually land. Understanding this distinction cuts "why won't my pod schedule" diagnosis from minutes to seconds.

---

## Video close — fast validation

**What happens when you run this:**
`kubectl top nodes` shows live CPU and memory usage if metrics-server is installed. The events tail shows recent node-level activity. Both read-only.

**Say:** "These three commands are my standard node health check. Top nodes gives live utilization — if a node is at 90% memory, I know where pressure is coming from before I even look at pods."

```bash
kubectl get nodes -o wide
kubectl top nodes 2>/dev/null || true
kubectl get events -A --sort-by=.lastTimestamp | tail -n 20
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-nodes.sh` | Wide node view and describe |
| `yamls/node-observation-notes.yaml` | Reference notes ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Node readiness and pressure hints |

---

## Next

[2.2.2 Communication between nodes and the control plane](../02-communication-between-nodes-and-the-control-plane/README.md)
