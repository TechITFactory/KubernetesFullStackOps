# 1.3.2 Running in Multiple Zones — teaching transcript

- **Summary**: Multi-zone Kubernetes improves resilience only when nodes, workloads, and storage choices are aligned with real failure domains.
- **Content**: Zone labeling checks, topology spread constraints, anti-affinity examples, and storage-zone awareness.
- **Lab**: Check zone labels on nodes, deploy a zone-spread workload, and confirm replicas distribute across availability zones.

## Assets

- `scripts/check-multi-zone-labels.sh`
- `yamls/multi-zone-deployment.yaml`
- `yamls/storage-zone-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

**Teaching tip:** **What happens when you run this** is below each Run block. See **WHAT THIS DOES WHEN YOU RUN IT** in `scripts/check-multi-zone-labels.sh`.

---

## Intro

Alright — here's the scenario.

You have a cluster spread across three availability zones. You feel good about redundancy. Then zone B goes down, and your service goes with it — because all your pod replicas happened to land in zone B.

**Multi-zone means nothing if your workloads aren't zone-aware.** Kubernetes won't spread pods across zones automatically unless you tell it to. And even when you do, there's a storage problem waiting: a PVC created in zone A cannot be used by a pod rescheduled to zone B.

This lesson covers:
- How Kubernetes knows which zone a node is in (topology labels)
- How to enforce spreading across those zones
- What the storage-zone trap looks like and how to avoid it

---

## Flow of this lesson

**Say:**
Three stages. First I check whether zone labels even exist on the nodes — without them, zone-aware scheduling is impossible. Then I deploy a workload with zone spread constraints. Then I verify the pods actually landed in different zones.

```
  [ Step 1 ]              [ Step 2 ]              [ Step 3 ]
  Check zone      →       Deploy zone-     →      Verify spread
  labels on              spread workload          across zones
  nodes
```

---

## Step 1 — Check zone labels on nodes

**What happens when you run this:**
`check-multi-zone-labels.sh` reads all node labels via the API and checks for `topology.kubernetes.io/zone` — the standard label Kubernetes and cloud providers use to identify availability zones. Exits with a warning if any node is missing the label. Read-only.

**Say:**
Before I do anything else, I need to know if the cluster actually has zone information on its nodes. A cloud-provisioned cluster (EKS, GKE, AKS) will have these labels automatically. A bare-metal cluster or a local cluster won't — and if the labels aren't there, zone-aware scheduling can't work.

**Run:**

```bash
./scripts/check-multi-zone-labels.sh
```

**Expected:**
Each node's zone label printed. If labels are missing, the script warns. On a local Minikube or Kind cluster this is expected — you can add labels manually for practice:

```bash
kubectl label node <node-name> topology.kubernetes.io/zone=zone-a
```

---

## Step 2 — Deploy the zone-spread workload

**What happens when you run this:**
`kubectl apply -f yamls/multi-zone-deployment.yaml` creates a Deployment where `topologySpreadConstraints` instructs the scheduler to distribute pods across values of `topology.kubernetes.io/zone`, keeping the maximum skew between zones at 1. Declarative; safe to re-apply.

**Say:**
Here's what zone spreading looks like in a Deployment spec. The key field is `topologySpreadConstraints` with `topologyKey: topology.kubernetes.io/zone`. The scheduler reads the zone label on each node and tries to keep pod counts balanced across zone values.

`maxSkew: 1` means: at most one extra pod in any zone compared to the least-loaded zone. So for three zones and six replicas, you'd expect 2/2/2. For five replicas across three zones, you'd get 2/2/1.

**Run:**

```bash
kubectl apply -f yamls/multi-zone-deployment.yaml
```

**Expected:**
Resources created or unchanged.

---

## Step 3 — Verify spread across zones

**What happens when you run this:**
`kubectl get pods -o wide` lists pods with node placement. `kubectl get nodes -L topology.kubernetes.io/zone` adds the zone label as a column. Cross-referencing these shows which zone each pod landed in.

**Say:**
I look at two things: which node each pod landed on, and which zone each node belongs to. If spread is working, I should see pods across multiple distinct zone values.

**Run:**

```bash
kubectl get nodes -L topology.kubernetes.io/zone
kubectl get pods -o wide
```

**Expected:**
Nodes show zone values in the `ZONE` column. Pods from the zone-spread Deployment distributed across nodes in different zones.

---

## The storage-zone trap

There is a failure pattern that trips teams who get zone spreading right for compute but wrong for storage.

**The problem:** `PersistentVolumeClaims` backed by cloud block storage (EBS, Persistent Disk, Azure Disk) are created in a specific availability zone. A pod that uses that PVC can only run in the same zone. If the pod is rescheduled to a different zone, it cannot mount the volume.

**The result:** a pod that stays `Pending` after rescheduling with an event like `volume node affinity conflict`.

**How to avoid it:**

1. **Stateless services** — use `topologySpreadConstraints` freely. No storage constraint.
2. **Stateful services with block storage** — use a `StorageClass` with `volumeBindingMode: WaitForFirstConsumer`. This delays volume creation until the scheduler picks a node, so the volume is created in the right zone.
3. **Stateful services across zones** — use distributed storage (Rook/Ceph, Portworx, or cloud-native distributed options) that is inherently zone-agnostic.

`yamls/storage-zone-notes.yaml` contains a ConfigMap with these patterns as reference — apply it to your cluster or read it as documentation.

```bash
kubectl apply -f yamls/storage-zone-notes.yaml
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/check-multi-zone-labels.sh` | Checks `topology.kubernetes.io/zone` on all nodes |
| `yamls/multi-zone-deployment.yaml` | Deployment with `topologySpreadConstraints` |
| `yamls/storage-zone-notes.yaml` | Storage-zone patterns and `WaitForFirstConsumer` reference |
| `yamls/failure-troubleshooting.yaml` | Zone label, skew, and storage-zone failure hints |

---

## Troubleshooting

- **Pods not spreading** → confirm zone labels exist (`kubectl get nodes --show-labels`); check `topologyKey` matches exactly
- **`whenUnsatisfiable: DoNotSchedule`** → pods go Pending if the constraint can't be met (e.g. fewer zones than replicas); switch to `ScheduleAnyway` for softer enforcement
- **Pod Pending after zone node failure** → check for PVC zone affinity conflict with `kubectl describe pod`; this is the storage-zone trap
- **Local cluster (Minikube/Kind)** → add zone labels manually to practice scheduling; actual zone failure simulation requires multiple nodes in different groups

---

## Learning objective

- Explain why zone labels are a prerequisite for zone-aware scheduling.
- Apply `topologySpreadConstraints` and verify pod distribution across zones.
- Describe the storage-zone trap and name two ways to avoid it.

## Why this matters

"We're in three zones" is not the same as "we survive a zone failure." The difference is whether your workloads are scheduled with zone-aware constraints and whether your storage is zone-agnostic. This lesson draws that line.

---

## Video close — fast validation

**What happens when you run this:**
Label check again; nodes with zone column; pod placement — read-only recap.

**Say:**
Same pattern as before a change or after a node event. Zone labels, node placement, pod distribution. These three lines take five seconds and tell you the zone health of your cluster at a glance.

```bash
./scripts/check-multi-zone-labels.sh
kubectl get nodes -L topology.kubernetes.io/zone
kubectl get pods -o wide
```

---

## Next

[1.3.3 Validate node setup](../1.3.3-validate-node-setup/README.md)
