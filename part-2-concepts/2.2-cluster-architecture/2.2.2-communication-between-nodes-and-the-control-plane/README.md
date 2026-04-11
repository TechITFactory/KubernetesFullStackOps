# 2.2.2 Communication between Nodes and the Control Plane — teaching transcript

## Intro

kubelet talks to the **API server**; node **Lease** heartbeats reduce status spam.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

**Teaching tip:** `inspect-node-control-plane-communication.sh` — script header.

## Lab — Quick Start

**What happens when you run this:**  
- Script lists nodes + leases in `kube-node-lease`.  
- You repeat the same gets for class practice.

```bash
chmod +x scripts/*.sh
./scripts/inspect-node-control-plane-communication.sh
kubectl get nodes
kubectl get lease -n kube-node-lease
```

**Expected:**  
Lease names align with nodes; renew times update over time.

## Video close — fast validation

**What happens when you run this:**  
Sample leases; recent `kube-system` events; nodes wide.

```bash
kubectl get lease -n kube-node-lease | head -n 20
kubectl get events -n kube-system --sort-by=.lastTimestamp | tail -n 20
kubectl get nodes -o wide
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-node-control-plane-communication.sh` | Nodes + leases |
| `yamls/node-control-plane-flow.yaml` | Reference |
| `yamls/failure-troubleshooting.yaml` | Registration / heartbeat |

## Next

[2.2.3 Controllers](../2.2.3-controllers/README.md)
