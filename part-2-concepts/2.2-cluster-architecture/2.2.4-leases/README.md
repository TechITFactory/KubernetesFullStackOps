# 2.2.4 Leases — teaching transcript

## Intro

**Lease** objects back node heartbeats and **leader election** for controllers.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

**Teaching tip:** `inspect-leases.sh` lists all namespaces’ leases — output can be wide.

## Lab — Quick Start

**What happens when you run this:**  
- Script: `kubectl get lease -A`.  
- You repeat and **describe** one lease in `kube-node-lease` (first by jsonpath).

```bash
chmod +x scripts/*.sh
./scripts/inspect-leases.sh
kubectl get lease -A
kubectl describe lease -n kube-node-lease "$(kubectl get lease -n kube-node-lease -o jsonpath='{.items[0].metadata.name}')"
```

**Expected:**  
`renewTime` present; correlates with heartbeat activity.

## Video close — fast validation

**What happens when you run this:**  
Focused lease list + nodes — read-only.

```bash
kubectl get lease -n kube-node-lease
kubectl get lease -A | head -n 20
kubectl get nodes
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-leases.sh` | All leases |
| `yamls/lease-notes.yaml` | Notes |
| `yamls/failure-troubleshooting.yaml` | Stale renewTime |

## Next

[2.2.5 Cloud controller manager](../2.2.5-cloud-controller-manager/README.md)
