# 1.3.2 Running in Multiple Zones — teaching transcript

## Intro

Alright — here's the scenario.

You have a cluster spread across three availability zones. You feel good about redundancy. Then zone B fails, and your service goes with it — because every replica landed in zone B.

**Multi-zone means nothing if workloads and storage ignore failure domains.** Kubernetes does not spread pods across zones unless you express it with labels and constraints. Even when you do, **zonal block storage** pins a volume to one zone; a pod using that disk cannot reschedule elsewhere without a new volume.

This lesson covers:

- The **`topology.kubernetes.io/zone`** label prerequisite on nodes
- **`topologySpreadConstraints`** keyed on zone topology
- **`volumeBindingMode: WaitForFirstConsumer`** on StorageClasses so disks are created in the zone the scheduler chooses
- A short **zone-failure narrative**: losing a zone removes nodes; spread plus PDBs controls how many replicas disappear at once, while storage class choices decide whether pods can come back elsewhere

**Teaching tip:** See **WHAT THIS DOES WHEN YOU RUN IT** in `scripts/check-multi-zone-labels.sh`.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/part-1-getting-started/1.3-best-practices/1.3.2-running-in-multiple-zones"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  [ Step 1 ]              [ Step 2 ]              [ Step 3 ]
  Zone label        →     Apply multi-zone    →     Verify pods
  check script            Deployment               vs zone columns
           │
           └──────────────────────┐
                                  ▼
                          storage-zone notes
                          (WaitForFirstConsumer)
```

**Say:**

First I prove zone labels exist, then I apply a Deployment that spreads on `topology.kubernetes.io/zone`, then I correlate pods to zones with `kubectl get nodes -L`. I finish by applying the storage notes ConfigMap that documents **`WaitForFirstConsumer`**.

---

## Step 1 — Check zone labels on nodes

**What happens when you run this:**

`check-multi-zone-labels.sh` reads node objects and checks for `topology.kubernetes.io/zone` — read-only. It may warn when labels are missing (common on local clusters).

**Say:**

Without this label, zone-aware scheduling is blind. Cloud providers usually inject it; bare metal and local VMs need you to add it for practice.

**Run:**

```bash
cd "$COURSE_DIR/part-1-getting-started/1.3-best-practices/1.3.2-running-in-multiple-zones"
chmod +x scripts/*.sh 2>/dev/null || true
./scripts/check-multi-zone-labels.sh
```

**Expected:**

Per-node zone output or explicit warnings. For manual practice on Kind/Minikube you may label a node:

```bash
kubectl label node <node-name> topology.kubernetes.io/zone=zone-a --overwrite
```

---

## Step 2 — Deploy the zone-spread workload

**What happens when you run this:**

`kubectl apply -f yamls/multi-zone-deployment.yaml` creates a Deployment whose `topologySpreadConstraints` target `topology.kubernetes.io/zone` with a small **`maxSkew`**.

**Say:**

The scheduler reads each node’s zone label and keeps replica counts balanced across distinct zone values whenever possible.

**Run:**

```bash
kubectl apply -f yamls/multi-zone-deployment.yaml
```

**Expected:**

Created or unchanged.

---

## Step 3 — Verify spread across zones

**What happens when you run this:**

`kubectl get nodes -L topology.kubernetes.io/zone` prints the zone column. `kubectl get pods -o wide` maps pods to nodes so you crosswalk into zones.

**Say:**

If zone A disappears in a real outage, only pods on nodes labeled with that zone value vanish immediately — spread and PDBs determine whether you still serve traffic.

**Run:**

```bash
kubectl get nodes -L topology.kubernetes.io/zone
kubectl get pods -o wide
```

**Expected:**

Nodes show `ZONE` values when labeled; pods list `NODE` names you can map to those zones.

---

## Step 4 — Apply storage-zone reference

**What happens when you run this:**

`kubectl apply -f yamls/storage-zone-notes.yaml` stores a ConfigMap that explains **`volumeBindingMode: WaitForFirstConsumer`** — provisioning waits until the scheduler picks a node so zonal disks land in the correct AZ.

**Say:**

Immediate binding created a disk in zone A while the pod later scheduled to zone B is the classic **volume node affinity conflict** failure mode. `WaitForFirstConsumer` avoids that race.

**Run:**

```bash
kubectl apply -f yamls/storage-zone-notes.yaml
```

**Expected:**

ConfigMap created or unchanged.

---

## Troubleshooting

- **`check-multi-zone-labels.sh` warns about missing zones** → expected on laptop clusters; add fake zone labels for practice or read the script output as “not zone-aware yet”
- **`0/N pods scheduled` with `DoNotSchedule` spread** → fewer zone values than replicas; temporarily lower replicas or set `whenUnsatisfiable: ScheduleAnyway` for softer labs
- **`pod has unbound immediate PersistentVolumeClaims` then Pending with volume affinity errors** → zonal PVC created before scheduling; switch StorageClass to **`WaitForFirstConsumer`** or delete/recreate PVCs in the correct zone
- **`topology.kubernetes.io/zone` typo in manifest** → key must match exactly what nodes expose (`kubectl get nodes --show-labels`)
- **`Forbidden` applying manifests** → use a cluster where you have create rights

---

## Learning objective

- Explained why **`topology.kubernetes.io/zone`** labels are prerequisites for zone-aware scheduling.
- Applied `topologySpreadConstraints` and read pod placement against node zone columns.
- Described the storage-zone trap and how **`WaitForFirstConsumer`** mitigates it.

## Why this matters

“We run in three zones” is not the same as surviving a zone loss. Spread rules, disruption budgets, and storage binding modes decide whether an availability zone failure becomes a blip or an outage.

## Video close — fast validation

**What happens when you run this:**

Read-only: rerun the label check, print zone column, list pods wide. `|| true` keeps a WARN exit code from stopping the closing take.

**Say:**

Same trio I run after any node or topology change: label script, zone column, pods wide.

**Run:**

```bash
./scripts/check-multi-zone-labels.sh || true
kubectl get nodes -L topology.kubernetes.io/zone
kubectl get pods -o wide
```

**Expected:**

Script output; nodes with zone column when labeled; pods listed.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/check-multi-zone-labels.sh` | Checks `topology.kubernetes.io/zone` on nodes |
| `yamls/multi-zone-deployment.yaml` | Deployment with zone spread |
| `yamls/storage-zone-notes.yaml` | `WaitForFirstConsumer` and zonal volume notes |
| `yamls/failure-troubleshooting.yaml` | Zone / skew / storage hints |

---

## Next

[1.3.3 Validate node setup](../1.3.3-validate-node-setup/README.md)
