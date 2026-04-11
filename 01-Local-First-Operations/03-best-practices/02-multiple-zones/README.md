# 02 Running in Multiple Zones â€” teaching transcript

## Intro

Alright â€” here's the scenario.

You have a cluster spread across three availability zones. You feel good about redundancy. Then zone B fails, and your service goes with it â€” because every replica landed in zone B.

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
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/03-best-practices/02-multiple-zones"
```

> If you set `COURSE_DIR` earlier, skip the export and just `cd`.

## Flow of this lesson

```
  [ Step 1 ]              [ Step 2 ]              [ Step 3 ]
  Zone label        â†’     Apply multi-zone    â†’     Verify pods
  check script            Deployment               vs zone columns
           â”‚
           â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
                                  â–¼
                          storage-zone notes
                          (WaitForFirstConsumer)
```

**Say:**

First I prove zone labels exist, then I apply a Deployment that spreads on `topology.kubernetes.io/zone`, then I correlate pods to zones with `kubectl get nodes -L`. I finish by applying the storage notes ConfigMap that documents **`WaitForFirstConsumer`**.

---

## Step 1 â€” Check zone labels on nodes

**What happens when you run this:**

`check-multi-zone-labels.sh` reads node objects and checks for `topology.kubernetes.io/zone` â€” read-only. It may warn when labels are missing (common on local clusters).

**Say:**

Without this label, zone-aware scheduling is blind. Cloud providers usually inject it; bare metal and local VMs need you to add it for practice.

**Run:**

```bash
cd "$COURSE_DIR/C:/src/K8sOps/01-Local-First-Operations/03-best-practices/02-multiple-zones"
chmod +x scripts/*.sh 2>/dev/null || true
./scripts/check-multi-zone-labels.sh
```

**Expected:**

Per-node zone output or explicit warnings. For manual practice on Kind/Minikube you may label a node:

```bash
kubectl label node <node-name> topology.kubernetes.io/zone=zone-a --overwrite
```

---

## Step 2 â€” Deploy the zone-spread workload

**What happens when you run this:**

`kubectl apply -f yamls/multi-zone-deployment.yaml` creates a Deployment whose `topologySpreadConstraints` target `topology.kubernetes.io/zone` with a small **`maxSkew`**.

**Say:**

The scheduler reads each nodeâ€™s zone label and keeps replica counts balanced across distinct zone values whenever possible.

**Run:**

```bash
kubectl apply -f yamls/multi-zone-deployment.yaml
```

**Expected:**

Created or unchanged.

---

## Step 3 â€” Verify spread across zones

**What happens when you run this:**

`kubectl get nodes -L topology.kubernetes.io/zone` prints the zone column. `kubectl get pods -o wide` maps pods to nodes so you crosswalk into zones.

**Say:**

If zone A disappears in a real outage, only pods on nodes labeled with that zone value vanish immediately â€” spread and PDBs determine whether you still serve traffic.

**Run:**

```bash
kubectl get nodes -L topology.kubernetes.io/zone
kubectl get pods -o wide
```

**Expected:**

Nodes show `ZONE` values when labeled; pods list `NODE` names you can map to those zones.

---

## Step 4 â€” Apply storage-zone reference

**What happens when you run this:**

`kubectl apply -f yamls/storage-zone-notes.yaml` stores a ConfigMap that explains **`volumeBindingMode: WaitForFirstConsumer`** â€” provisioning waits until the scheduler picks a node so zonal disks land in the correct AZ.

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

- **`check-multi-zone-labels.sh` warns about missing zones** â†’ expected on laptop clusters; add fake zone labels for practice or read the script output as â€œnot zone-aware yetâ€
- **`0/N pods scheduled` with `DoNotSchedule` spread** â†’ fewer zone values than replicas; temporarily lower replicas or set `whenUnsatisfiable: ScheduleAnyway` for softer labs
- **`pod has unbound immediate PersistentVolumeClaims` then Pending with volume affinity errors** â†’ zonal PVC created before scheduling; switch StorageClass to **`WaitForFirstConsumer`** or delete/recreate PVCs in the correct zone
- **`topology.kubernetes.io/zone` typo in manifest** â†’ key must match exactly what nodes expose (`kubectl get nodes --show-labels`)
- **`Forbidden` applying manifests** â†’ use a cluster where you have create rights

---

## Learning objective

- Explained why **`topology.kubernetes.io/zone`** labels are prerequisites for zone-aware scheduling.
- Applied `topologySpreadConstraints` and read pod placement against node zone columns.
- Described the storage-zone trap and how **`WaitForFirstConsumer`** mitigates it.

## Why this matters

â€œWe run in three zonesâ€ is not the same as surviving a zone loss. Spread rules, disruption budgets, and storage binding modes decide whether an availability zone failure becomes a blip or an outage.

## Video close â€” fast validation

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

[03 Validate node setup](../03-validate-node-setup/README.md)
