# 02.1.5 Options for Highly Available Topology

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/02-production-environment/03-kubeadm-ha-topology-options"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  read stacked vs external etcd  â†’  load balancer / quorum story  â†’  record topology choice
```

**Say:**

HA is an operations contract â€” I pick stacked or external etcd before I buy hardware and load balancers.

---

- **Summary**: Choose between stacked etcd and external etcd HA topologies based on failure domain requirements, team operational capacity, and recovery objectives.
- **Content**: What HA means for Kubernetes, stacked vs external etcd trade-offs, load balancer requirements, quorum fundamentals.
- **Lab**: Run `ha-prereqs-check.sh` to confirm infrastructure prerequisites, review `ha-topology-options.yaml`, record your topology decision and rationale.

## Files

| Path | Purpose |
|------|---------|
| `scripts/ha-prereqs-check.sh` | Checks CLI tools, environment variables, and prints topology node-count requirements |
| `yamls/ha-topology-options.yaml` | Structured comparison of stacked vs external etcd â€” use as a decision record |

**Teaching tip:** **What happens when you run this** is below; the check scriptâ€™s behavior is in **WHAT THIS DOES WHEN YOU RUN IT** in `scripts/ha-prereqs-check.sh`.

## Quick Start

**What happens when you run this:**  
- `ha-prereqs-check.sh` â€” prints whether `kubectl`/`kubeadm` exist and whether `CONTROL_PLANE_ENDPOINT` / `ETCD_ENDPOINTS` env vars are set; prints topology reminders â€” **no cluster changes**.  
- `cat ha-topology-options.yaml` â€” prints the reference YAML to stdout (read-only).

```bash
# Check prerequisites
CONTROL_PLANE_ENDPOINT=api.mycompany.com:6443 ./scripts/ha-prereqs-check.sh

# Review topology options
cat yamls/ha-topology-options.yaml
```

---

## Transcript â€” 10-Minute Lesson

### [0:00â€“0:45] Hook

Everything we have built so far has a single point of failure: the control-plane node. If that one server goes down â€” hardware failure, kernel panic, accidental shutdown â€” the entire cluster loses its brain.

Existing workloads keep running (Kubernetes is designed for this), but you cannot deploy anything new, you cannot scale anything, you cannot recover failed pods. The cluster is alive but you cannot drive it.

High Availability eliminates that single point of failure. This lesson is about choosing how.

---

### [0:45â€“2:00] What HA Actually Means for Kubernetes

A Kubernetes control plane has four components: API server, controller-manager, scheduler, and etcd.

The first three (API server, controller-manager, scheduler) are relatively easy to make highly available â€” they are stateless, so you can run multiple replicas. Only one controller-manager and one scheduler are active at a time (they use leader election), but multiple replicas are running and ready to take over.

**etcd is different.** etcd is a **distributed key-value store** that holds the entire cluster state â€” every pod, every service, every config, every secret. It is stateful, it uses a consensus algorithm (Raft) for consistency, and it requires a majority of members to be healthy to function.

HA Kubernetes is really about HA etcd. Get etcd right, and the rest follows.

---

### [2:00â€“4:30] Stacked etcd Topology

In the **stacked** topology, each control-plane node runs etcd alongside the API server, controller-manager, and scheduler:

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Control-Plane Node 1           â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”‚
â”‚  â”‚ API Serverâ”‚  â”‚  etcd    â”‚    â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”‚
â”‚  â”‚ Ctrl-Mgr â”‚  â”‚ Schedulerâ”‚    â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
   (replicated Ã— 3 nodes)
```

**Minimum: 3 control-plane nodes** â€” needed for etcd quorum (can tolerate 1 failure).

**Advantages:**
- Simpler infrastructure â€” fewer node types to manage.
- kubeadm handles everything â€” no separate etcd cluster to provision.
- Lower cost â€” fewer total servers.

**Disadvantages:**
- Control-plane and etcd share failure domain. A misconfigured API server that floods disk I/O could degrade etcd on the same node.
- Scaling control-plane nodes means scaling etcd nodes simultaneously â€” you cannot scale them independently.

**Best for**: most teams. This is the topology the majority of production kubeadm clusters use.

---

### [4:30â€“6:00] External etcd Topology

In the **external** topology, etcd runs on dedicated nodes separate from the Kubernetes control plane:

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  etcd Node 1  â”‚    â”‚  etcd Node 2  â”‚    â”‚  etcd Node 3  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
         â†‘                    â†‘                    â†‘
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Control-Plane Node 1   Control-Plane Node 2   ...     â”‚
â”‚  (API server, ctrl-mgr, scheduler â€” no etcd)           â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

**Minimum: 3 etcd nodes + 3 control-plane nodes = 6 nodes total**.

**Advantages:**
- Separate failure domains â€” a control-plane problem cannot take down etcd and vice versa.
- Independent scaling â€” you can add control-plane nodes without touching etcd, and vice versa.
- etcd gets dedicated disk and network resources (critical for performance).

**Disadvantages:**
- More infrastructure â€” six or more nodes vs three.
- More operational complexity â€” separate certificate management, separate backup procedures, separate monitoring.
- kubeadm does not manage the etcd cluster â€” you provision and maintain it separately.

**Best for**: large clusters, clusters with strict separation-of-concerns requirements (compliance), or teams with dedicated platform/SRE capacity to manage etcd independently.

---

### [6:00â€“7:15] The Load Balancer Requirement

Both topologies require a **load balancer** in front of the control-plane API servers.

```
kubectl / workers / other tools
          â†“
   Load Balancer :6443
    â†™      â†“      â†˜
CP Node1  CP Node2  CP Node3
  :6443    :6443    :6443
```

The load balancer provides a stable endpoint (`CONTROL_PLANE_ENDPOINT`) that does not change when individual control-plane nodes are added, removed, or replaced. Worker nodes and kubectl both talk to this endpoint â€” they do not talk directly to individual control-plane nodes.

In the cloud: use a cloud load balancer (ALB, NLB, GCP Load Balancer, Azure LB).
On-premise: use HAProxy, keepalived + VIP, or an F5.

The endpoint must be set in kubeadm config **before** init:
```yaml
controlPlaneEndpoint: "api.mycompany.com:6443"
```
You cannot change this after init without significant surgery.

---

### [7:15â€“8:15] Quorum â€” Why Odd Numbers

etcd uses the **Raft consensus algorithm**. To commit a write, a majority of etcd members must agree.

The majority threshold for N members is `(N/2) + 1`:

| Members | Quorum needed | Failure tolerance |
|---------|--------------|------------------|
| 1 | 1 | 0 |
| 2 | 2 | 0 |
| 3 | 2 | **1** |
| 4 | 3 | 1 |
| 5 | 3 | **2** |
| 6 | 4 | 2 |
| 7 | 4 | **3** |

Notice: 4 members tolerate 1 failure â€” same as 3. 6 members tolerate 2 failures â€” same as 5. **Even numbers buy you nothing.** Always use odd numbers: 3, 5, or 7.

3 is the minimum for any fault tolerance. 5 is typical for large production clusters. Beyond 7, the write latency penalty from requiring quorum across more members outweighs the fault tolerance benefit.

---

### [8:15â€“9:30] Choosing Your Topology

Use this decision checklist:

```
Do you have dedicated infrastructure/SRE capacity to operate etcd separately?
â”œâ”€â”€ No  â†’ Stacked etcd (3 control-plane nodes)
â””â”€â”€ Yes â†’ Do you have strict separation-of-concerns requirements?
          â”œâ”€â”€ No  â†’ Stacked etcd (simpler, cheaper)
          â””â”€â”€ Yes â†’ External etcd (3 control-plane + 3 etcd nodes)
```

Record your decision in `ha-topology-options.yaml` with the reason. When you revisit this cluster in 18 months, you want to know why you chose what you chose.

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common HA topology mismatch, quorum, and endpoint design failures.

**Most teams choose stacked.** External etcd is a meaningful operational investment â€” only make it if you have the capacity to maintain a separately operated etcd cluster.

---

### [9:30â€“10:00] Recap

- **HA Kubernetes** = multiple control-plane nodes + stable load balancer endpoint. etcd is the hardest part.
- **Stacked etcd** = etcd runs on control-plane nodes. Simpler. Minimum 3 nodes. Best for most teams.
- **External etcd** = etcd on dedicated nodes. Separate failure domains. Minimum 6 nodes. Best for large/regulated environments.
- **Load balancer** = mandatory in both topologies. Stable endpoint for API server. Set in config before init.
- **Quorum** = always odd numbers. 3 nodes = tolerate 1 failure. 5 nodes = tolerate 2.

Next: 02.1.6 â€” Creating Highly Available Clusters with kubeadm, where we run the stacked HA init and join additional control-plane nodes.

## Video close â€” fast validation

**What happens when you run this:**  
Read-only snapshot: nodes with IPs, first screen of `kube-system` pods â€” confirms a live cluster context.

```bash
kubectl get nodes -o wide
kubectl get pods -n kube-system -o wide | head
```
