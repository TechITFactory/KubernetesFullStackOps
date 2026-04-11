# 2.10 Scheduling, Preemption and Eviction — teaching transcript

## Intro

The **kube-scheduler** **binds** **unscheduled** **Pods** **to** **Nodes** **using** **filters** **(predicates)** **and** **scores** **(priorities)** **implemented** **as** **plugins** **in** **the** **scheduling** **framework**. Around that core, this module covers **how** **you** **steer** **placement** (**affinity**, **taints**, **topology** **spread**, **overhead**, **scheduling** **readiness**), **how** **platform** **teams** **tune** **performance** **and** **packing**, **when** **priority** **triggers** **preemption**, and **how** **the** **kubelet** **and** **API** **evict** **workloads** **under** **pressure** **or** **disruption** **policy**. **Dynamic** **Resource** **Allocation** **and** **gang** **scheduling** **topics** **bridge** **to** **modern** **GPU** **and** **batch** **patterns**.

**Prerequisites:** [2.9 Policies](../09-policies/README.md) (quotas and allocatable context); [2.7.4 Resource management for pods and containers](../07-configuration/04-resource-management-for-pods-and-containers/README.md) (requests, limits, QoS); [2.4 Workloads](../04-workloads/README.md) (Pod lifecycle vocabulary).

## Flow of this lesson

```
  Scheduler bind path (filter → score → bind)
              │
              ├── Steering: nodeSelector, affinity, taints, spread, overhead, gates
              ├── Framework plugins, DRA, gang / batch schedulers (concept + APIs)
              ├── Tuning and bin packing (operator knobs)
              └── Priority, preemption, node pressure, API eviction, node features
```

**Say:**

I **always** **pair** **`kubectl describe pod`** **Events** **with** **`FailedScheduling`** **messages** **when** **teaching** **affinity**—**the** **scheduler** **tells** **you** **exactly** **which** **predicate** **failed**.

## Learning objective

- Trace **why** **a** **Pod** **stays** **Pending** **using** **events**, **node** **labels**, **taints**, and **resource** **requests**.
- Contrast **scheduler** **preemption** **(priority)** **with** **kubelet** **eviction** **(pressure)** **and** **API** **eviction** **(PDB-aware)**.

## Why this matters

**Misconfigured** **affinity** **or** **missing** **tolerations** **silently** **blocks** **deployments** **at** **scale**; **priority** **without** **PDBs** **surprises** **teams** **during** **node** **drains**.

## Children (suggested order)

1. [2.10.1 Kubernetes Scheduler](01-kubernetes-scheduler/README.md)
2. [2.10.2 Assigning Pods to Nodes](02-assigning-pods-to-nodes/README.md)
3. [2.10.3 Pod Overhead](03-pod-overhead/README.md)
4. [2.10.4 Pod Scheduling Readiness](04-pod-scheduling-readiness/README.md)
5. [2.10.5 Pod Topology Spread Constraints](05-pod-topology-spread-constraints/README.md)
6. [2.10.6 Taints and Tolerations](06-taints-and-tolerations/README.md)
7. [2.10.7 Scheduling Framework](07-scheduling-framework/README.md)
8. [2.10.8 Dynamic Resource Allocation](08-dynamic-resource-allocation/README.md)
9. [2.10.9 Gang Scheduling](09-gang-scheduling/README.md)
10. [2.10.10 Scheduler Performance Tuning](10-scheduler-performance-tuning/README.md)
11. [2.10.11 Resource Bin Packing](11-resource-bin-packing/README.md)
12. [2.10.12 Pod Priority and Preemption](12-pod-priority-and-preemption/README.md)
13. [2.10.13 Node-pressure Eviction](13-node-pressure-eviction/README.md)
14. [2.10.14 API-initiated Eviction](14-api-initiated-eviction/README.md)
15. [2.10.15 Node Declared Features](15-node-declared-features/README.md)

## Module wrap — quick validation

**What happens when you run this:** **Pending** **workloads**, **scheduler** **lease**, and **PriorityClass** **inventory**.

**Say:**

Before **2.10.12**, I **list** **`PriorityClass`** **objects** **so** **viewers** **see** **system** **defaults** **like** **`system-cluster-critical`**.

```bash
kubectl get pods -A --field-selector=status.phase=Pending 2>/dev/null | head -n 20 || true
kubectl get lease -n kube-system 2>/dev/null | grep -i scheduler | head -n 5 || true
kubectl get priorityclass 2>/dev/null | head -n 15 || true
```

## Troubleshooting

- **`FailedScheduling` opaque** → **raise** **scheduler** **log** **verbosity** **(platform)** **or** **use** **events** **`--sort-by=.lastTimestamp`**
- **No** **scheduler** **pod** **visible** → **managed** **control** **plane** **hides** **it**—**narrate** **the** **same** **semantics**
- **Preemption** **blame** **games** → **capture** **`kubectl get pod -o yaml`** **priority** **and** **PDB** **state** **at** **incident** **time**
- **Wrong** **cluster** → **`kubectl config current-context`**

## Next

[2.11 Cluster administration](../2.11-cluster-administration/README.md)
