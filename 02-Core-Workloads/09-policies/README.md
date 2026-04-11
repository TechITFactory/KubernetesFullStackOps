# 2.9 Policies — teaching transcript

## Intro

**Policies** in this module are **admission-time** and **node-level** **guardrails** for **fair sharing** and **stability**: **LimitRange** sets **defaults** and **maxima** per **Pod** or **container** in a **namespace**; **ResourceQuota** caps **aggregate** **consumption** of **compute**, **objects**, and **storage** **classes**; **PID** **limits** and **reservations** prevent **fork** **bombs** and **cgroup** **pids** **exhaustion**; **node** **resource** **managers** (**CPU** **Manager**, **Device** **Manager**, **Topology** **Manager**) align **exclusive** **CPU**, **devices**, and **NUMA** **placement** with **what** **the** **scheduler** **promised**. Pair these lessons with [2.7.4 Resource management for pods and containers](../07-configuration/04-resource-management-for-pods-and-containers/README.md) and [2.8 Security](../08-security/README.md) for **multi-tenant** **namespaces**.

**Prerequisites:** [2.8 Security](../08-security/README.md) (namespace boundaries and shared clusters); [2.7.4 Resource management for pods and containers](../07-configuration/04-resource-management-for-pods-and-containers/README.md) (requests, limits, QoS).

## Flow of this lesson

```
  Per-namespace defaults and ceilings (LimitRange)
              │
              ▼
  Namespace totals and object counts (ResourceQuota)
              │
              ▼
  PID cgroup limits + kubelet reservations
              │
              ▼
  Node: CPU / device / topology managers (kubelet)
```

**Say:**

I **demo** **LimitRange** **first** so **developers** **see** **defaults** **before** I **show** **Quota** **blocking** **the** **whole** **namespace**.

## Learning objective

- Run **read-only** **`kubectl`** **inspections** for **LimitRange** and **ResourceQuota** across **namespaces**.
- Explain **why** **PID** **limits** and **node** **resource** **managers** sit **below** **API** **objects** but **above** **the** **kernel**.

## Why this matters

**No** **quotas** **means** **one** **team** **can** **starve** **etcd** **and** **the** **scheduler** **with** **object** **count** **or** **steal** **all** **cluster** **CPU** **in** **their** **namespace** **unless** **platform** **caps** **exist**.

## Children (suggested order)

1. [2.9.1 Limit Ranges](01-limit-ranges/README.md)
2. [2.9.2 Resource Quotas](02-resource-quotas/README.md)
3. [2.9.3 Process ID Limits and Reservations](03-process-id-limits-and-reservations/README.md)
4. [2.9.4 Node Resource Managers](04-node-resource-managers/README.md)

## Module wrap — quick validation

**What happens when you run this:** Lists **LimitRange** and **ResourceQuota** in all namespaces (same aggregate view as the per-lesson inspect scripts).

**Say:**

Before **2.9.2**, I **snapshot** **whether** **any** **namespace** **already** **has** **Quota**—**managed** **clusters** **often** **ship** **system** **quotas**.

```bash
kubectl get limitrange,resourcequota -A 2>/dev/null | head -n 40 || true
kubectl get ns --show-labels 2>/dev/null | head -n 15
```

## Troubleshooting

- **`Forbidden` applying notes ConfigMaps** → **cluster** **RBAC** blocks **kube-system**; **teach** **from** **offline** **YAML** **or** **use** **a** **dev** **namespace** **copy** **with** **adjusted** **`metadata.namespace`**
- **Empty** **`limitrange`/`resourcequota`** → **normal** **on** **fresh** **minikube**; **narrate** **what** **you** **would** **add**
- **Confusion** **between** **LimitRange** **and** **Quota** → **LimitRange** **per** **Pod** **default**/**max**; **Quota** **sum** **across** **namespace**
- **Wrong** **cluster** → **`kubectl config current-context`**

## Next

[2.11 Cluster administration](../2.11-cluster-administration/README.md)
