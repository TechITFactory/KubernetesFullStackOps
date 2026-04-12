# Communication between Nodes and the Control Plane — teaching transcript

## Intro

Nodes and the control plane communicate in one direction: **kubelet initiates, the API server receives**. The control plane never dials into a node. This design means nodes can live behind NAT or firewalls with no inbound access — only outbound HTTPS to the API server is required.

The kubelet sends two types of traffic to the API server: **status updates** (node conditions, pod states) and **Lease heartbeats**. Leases are lightweight objects in the `kube-node-lease` namespace updated every 10 seconds. If the API server stops receiving Lease renewals for 40 seconds, it marks the node `Unknown`. This threshold is controlled by `--node-monitor-grace-period` on the controller manager (default 40s).

Kubelet-to-API-server communication is authenticated with TLS client certificates. If those certificates expire, the kubelet can no longer communicate, and the node goes `Unknown` even though the machine is running fine.

**Prerequisites:** [Part 1](../../../01-Local-First-Operations/README.md).

---

## Flow of this lesson

```
  [ Step 1 ]                [ Step 2 ]
  Run inspection   →        Inspect Lease objects
  script                    (renewTime, node alignment)
  (nodes + leases)
```

**Say:** "Two steps. First the script gives us a combined view of nodes and their Lease objects. Then we look at the Lease objects directly to see the renewTime field — that's the heartbeat timestamp."

---

## Step 1 — Run the inspection script

**What happens when you run this:**
`inspect-node-control-plane-communication.sh` lists nodes and all Leases in `kube-node-lease` together. All read-only.

**Say:** "The script puts nodes and leases side by side so you can confirm that every node has a matching Lease object and that the Lease names align with node names. If a node shows `Unknown` and you look at its Lease, you'll find the renewTime is stale — stuck in the past."

**Run:**

```bash
chmod +x scripts/*.sh
./scripts/inspect-node-control-plane-communication.sh
kubectl get nodes
kubectl get lease -n kube-node-lease
```

**Expected:**
One Lease per node. Lease names match node names. `HOLDER` column in Lease output matches node names.

---

## Step 2 — Read a Lease in detail

**What happens when you run this:**
`kubectl describe lease` on the first Lease shows `renewTime` — the timestamp of the last heartbeat from that node's kubelet. This updates every 10 seconds on a healthy node.

**Say:** "renewTime is the single most important field in a Lease object. A healthy kubelet updates this every 10 seconds. If you run this twice 15 seconds apart and renewTime hasn't changed, the kubelet on that node has stopped sending heartbeats. Check kubelet status on the node immediately."

**Run:**

```bash
kubectl describe lease -n kube-node-lease \
  "$(kubectl get lease -n kube-node-lease -o jsonpath='{.items[0].metadata.name}')"
```

**Expected:**
`renewTime` shows a recent timestamp (within the last minute). `holderIdentity` matches the node name.

---

## Troubleshooting

- **`Node status Unknown`** → check the node's Lease renewTime with `kubectl describe lease -n kube-node-lease <node-name>`; if it is stale, the kubelet has stopped heartbeating; SSH to the node and check `systemctl status kubelet`.
- **`kubelet certificate expired`** → the kubelet uses TLS client certs to authenticate to the API server; expired certs cause communication to fail silently from the node's perspective; check `journalctl -u kubelet | grep "certificate"` and renew with `kubeadm certs renew all` then restart the kubelet.
- **`Lease not found for a node`** → the Lease object is created by the kubelet on first contact; if the kubelet has never successfully communicated, the Lease won't exist; check kubelet logs for connection errors.
- **`renewTime not updating`** → kubelet is running but not reaching the API server; check network connectivity from the node to the API server endpoint with `curl -k https://<api-server>:6443/readyz`; check firewall rules allowing outbound HTTPS from nodes.
- **`kube-node-lease namespace missing`** → this namespace is created automatically; if it is absent, the cluster may have been set up with an old version or the namespace was manually deleted; recreate it with `kubectl create namespace kube-node-lease`.

---

## Learning objective

- Explain why kubelet initiates communication to the API server, not the reverse.
- Describe what a Lease object is and what renewTime tells you.
- Use `kubectl describe lease` to diagnose a node heartbeat issue.

## Why this matters

When a node goes `Unknown`, the first question is always "is the machine dead or is it just not talking to the API server?" The Lease renewTime answers that immediately. A stale Lease with a live machine means a communication or authentication problem. A missing Lease means the kubelet never connected at all. These two cases have completely different remediation paths.

---

## Video close — fast validation

**What happens when you run this:**
Leases; kube-system events; nodes wide — read-only recap of communication health.

**Say:** "Leases, events, nodes — these three commands confirm the communication loop is healthy. If renewTime is current and nodes are Ready, the heartbeat path is working."

```bash
kubectl get lease -n kube-node-lease | head -n 20
kubectl get events -n kube-system --sort-by=.lastTimestamp | tail -n 20
kubectl get nodes -o wide
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-node-control-plane-communication.sh` | Nodes and Leases combined view |
| `yamls/node-control-plane-flow.yaml` | Reference ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Heartbeat and registration failure hints |

---

## Next

[2.2.3 Controllers](../03-controllers/README.md)
