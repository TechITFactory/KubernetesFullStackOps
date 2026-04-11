# 2.2.4 Leases â€” teaching transcript

## Intro

A **Lease** is a lightweight Kubernetes object used for two purposes: **node heartbeats** and **leader election**.

For node heartbeats, each node's kubelet updates a Lease object in the `kube-node-lease` namespace every 10 seconds. The controller manager watches these Leases. If a Lease goes unrenewed for 40 seconds, the node is marked `Unknown`. This design offloads the heartbeat work from the Node object itself â€” instead of updating a large Node status object every 10 seconds, the kubelet updates only the small Lease, reducing API server load significantly.

For leader election, `kube-controller-manager` and `kube-scheduler` each hold a Lease in the `kube-system` namespace. In an HA control plane, only the leader actively runs the reconcile loop. The other replicas watch the Lease and take over if the leader stops renewing.

**Prerequisites:** [Part 1](../../../part-1-getting-started/README.md).

---

## Flow of this lesson

```
  [ Step 1 ]              [ Step 2 ]
  Run script       â†’      Describe one Lease
  (list all Leases        (renewTime, holderIdentity)
  across namespaces)
```

**Say:** "Two steps. First we list all Leases across the cluster â€” node heartbeat Leases in kube-node-lease, and leader election Leases in kube-system. Then we describe one to see the renewTime field, which is the timestamp of the last heartbeat."

---

## Step 1 â€” List all Leases

**What happens when you run this:**
`inspect-leases.sh` runs `kubectl get lease -A`, listing all Leases across all namespaces. `kubectl get lease -A` repeats this so you can observe it directly.

**Say:** "Two groups appear in this list. kube-node-lease holds one Lease per node â€” these are heartbeats. kube-system holds Leases for kube-controller-manager and kube-scheduler â€” these are leader election locks. On a single-node or single-control-plane cluster, the leader election Leases exist but there's no competition for them."

**Run:**

```bash
chmod +x scripts/*.sh
./scripts/inspect-leases.sh
kubectl get lease -A
```

**Expected:**
`kube-node-lease` namespace shows one Lease per node. `kube-system` shows Leases for `kube-controller-manager` and `kube-scheduler`. HOLDER column populated.

---

## Step 2 â€” Describe a node Lease

**What happens when you run this:**
`kubectl describe lease` on the first Lease in `kube-node-lease` shows `renewTime` â€” the timestamp of the last heartbeat from that node's kubelet.

**Say:** "renewTime is the key field. On a healthy node this updates every 10 seconds. If you run this command twice, 15 seconds apart, and renewTime hasn't changed â€” the kubelet on that node has stopped heartbeating. That's your first diagnostic signal before you even SSH to the machine."

**Run:**

```bash
kubectl describe lease -n kube-node-lease \
  "$(kubectl get lease -n kube-node-lease -o jsonpath='{.items[0].metadata.name}')"
```

**Expected:**
`renewTime` shows a recent timestamp (within the last minute). `holderIdentity` matches the node name.

---

## Troubleshooting

- **`renewTime is stale (not updating)`** â†’ the kubelet on that node has stopped; SSH to the node and check `systemctl status kubelet`; also check `journalctl -u kubelet -n 50` for errors.
- **`kube-controller-manager Lease shows wrong holder`** â†’ in an HA cluster, the active leader holds the Lease; if the leader crashed and another replica took over, the holder name changes; this is normal behavior, not an error.
- **`No Leases in kube-node-lease`** â†’ the kubelet has never successfully connected to the API server; check kubelet logs and API server connectivity from the node.
- **`Leader election Lease missing from kube-system`** â†’ the kube-controller-manager or kube-scheduler may not be running; check `kubectl get pods -n kube-system` for their pods.
- **`Node marked Unknown despite machine being alive`** â†’ check the Lease renewTime; if stale, the kubelet is not talking to the API server â€” check network and TLS certificates; if renewTime is current, the issue is elsewhere in node conditions.

---

## Learning objective

- Explain the two uses of Lease objects: node heartbeats and leader election.
- Identify `renewTime` in a Lease and explain what a stale value means.
- Distinguish the Leases in `kube-node-lease` from those in `kube-system`.

## Why this matters

Leases are the mechanism behind two of the most important operational signals in Kubernetes: whether a node is alive, and which control-plane replica is the active leader. When a node goes `Unknown`, the Lease renewTime tells you immediately whether the machine has lost connectivity or the kubelet has crashed. That distinction changes your remediation entirely.

---

## Video close â€” fast validation

**What happens when you run this:**
Focused Lease list for node heartbeats; all Leases; nodes. All read-only.

**Say:** "Three commands: node Leases to confirm heartbeats, all Leases to see the full picture, and nodes to cross-check Ready status. If renewTime is current and nodes are Ready, the heartbeat path is healthy."

```bash
kubectl get lease -n kube-node-lease
kubectl get lease -A | head -n 20
kubectl get nodes
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-leases.sh` | Lists all Leases across namespaces |
| `yamls/lease-notes.yaml` | Reference notes ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Stale renewTime and leader election hints |

---

## Next

[2.2.5 Cloud controller manager](../05-cloud-controller-manager/README.md)
