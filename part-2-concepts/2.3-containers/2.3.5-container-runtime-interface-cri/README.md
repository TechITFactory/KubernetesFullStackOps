# 2.3.5 Container Runtime Interface (CRI) — teaching transcript

## Intro

**kubelet → CRI → runtime** (containerd, CRI-O, cri-dockerd). Troubleshooting “pods won’t start” often lands on **socket path** and **cgroup driver** alignment — same themes as Part 1 node setup.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

**Teaching tip:** Run **`inspect-cri-endpoint.sh` on a cluster node** (SSH / cloud node session). From kubectl-only laptop it may print **no sockets** — that is expected.

## Lab — Quick Start

**What happens when you run this:**  
- Script scans common **Unix socket** paths; if `crictl` exists, runs **`crictl info`** against the first socket found (may need `sudo` on your distro — run `sudo ./scripts/...` if permission denied).  
- `kubectl apply cri-notes.yaml` creates **`kube-system`** ConfigMap `cri-notes` (needs RBAC to write `kube-system`).  
- `kubectl get nodes` — read-only cluster view.

```bash
chmod +x scripts/*.sh
./scripts/inspect-cri-endpoint.sh
kubectl apply -f yamls/cri-notes.yaml
kubectl get nodes -o wide
```

**Expected:**  
At least one “Found CRI socket” line on a real node, or a clear warning; ConfigMap applies if allowed.

## Video close — fast validation

**What happens when you run this:**  
Nodes; first chunk of `kube-system` pods (runtime/CNI/kubelet-related) — read-only.

```bash
kubectl get nodes -o wide
kubectl get pods -n kube-system -o wide | head -n 15
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-cri-endpoint.sh` | Local socket scan + optional `crictl info` |
| `yamls/cri-notes.yaml` | In-cluster CRI notes (kube-system) |
| `yamls/failure-troubleshooting.yaml` | Socket / crictl / kubelet alignment |

## Cleanup

```bash
kubectl delete configmap cri-notes -n kube-system --ignore-not-found
```

## Next

[2.4 Workloads](../../2.4-workloads/README.md)
