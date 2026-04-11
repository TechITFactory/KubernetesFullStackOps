# 2.2.1 Nodes — teaching transcript

## Intro

Nodes: kubelet, kube-proxy, runtime; **capacity**, **allocatable**, **conditions**, roles.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

**Teaching tip:** `scripts/inspect-nodes.sh` — see file header.

## Lab — Quick Start

**What happens when you run this:**  
- Script: wide nodes + truncated multi-node describe.  
- You repeat wide get.  
- You describe **first** node (by jsonpath), first 80 lines.

```bash
chmod +x scripts/*.sh
./scripts/inspect-nodes.sh
kubectl get nodes -o wide
kubectl describe node "$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')" | sed -n '1,80p'
```

**Expected:**  
`Ready`, roles, runtime/version strings visible; capacity/allocatable in describe.

## Video close — fast validation

**What happens when you run this:**  
`kubectl top nodes` if metrics-server installed (`|| true`); recent events.

```bash
kubectl get nodes -o wide
kubectl top nodes 2>/dev/null || true
kubectl get events -A --sort-by=.lastTimestamp | tail -n 20
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-nodes.sh` | Node inspection |
| `yamls/node-observation-notes.yaml` | Notes |
| `yamls/failure-troubleshooting.yaml` | Node readiness |

## Next

[2.2.2 Communication between nodes and the control plane](../2.2.2-communication-between-nodes-and-the-control-plane/README.md)
