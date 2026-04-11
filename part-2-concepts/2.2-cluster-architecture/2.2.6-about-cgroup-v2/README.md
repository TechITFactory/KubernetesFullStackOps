# 2.2.6 About cgroup v2 — teaching transcript

## Intro

**cgroup v2** unified hierarchy — kubelet + runtime **cgroup driver** should align (usually `systemd`).

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

**Teaching tip:** `check-cgroup-version.sh` reads **the local machine’s** `/sys/fs/cgroup` — run on a **node** (SSH), not only from your laptop unless your laptop is the node.

## Lab — Quick Start

**What happens when you run this:**  
- Host script prints v1 vs v2 detection.  
- `kubectl` shows nodes and describe snippets for runtime/kubelet version.

```bash
chmod +x scripts/*.sh
./scripts/check-cgroup-version.sh
kubectl get nodes -o wide
kubectl describe node "$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')" | grep -i -E 'container runtime|kubelet version' || true
```

**Expected:**  
Clear cgroup mode message; node info lines for cross-check.

## Video close — fast validation

**What happens when you run this:**  
`stat` cgroup fs type; nodes; recent events.

```bash
stat -fc %T /sys/fs/cgroup
kubectl get nodes -o wide
kubectl get events -A --sort-by=.lastTimestamp | tail -n 20
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/check-cgroup-version.sh` | Local cgroup detect |
| `yamls/cgroup-v2-notes.yaml` | Notes |
| `yamls/failure-troubleshooting.yaml` | Driver mismatch |

## Next

[2.2.7 Kubernetes self-healing](../2.2.7-kubernetes-self-healing/README.md)
