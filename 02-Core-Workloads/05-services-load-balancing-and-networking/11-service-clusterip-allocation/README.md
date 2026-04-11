# 2.5.11 Service ClusterIP Allocation â€” teaching transcript

## Intro

Each **ClusterIP** address is allocated from a **cluster IP range** configured for the **API server** (flags like **`--service-cluster-ip-range`**) and tracked to avoid collisions. **Services** of type **ClusterIP** (and the internal parts of **NodePort** / **LoadBalancer**) consume addresses from that range. **Exhaustion** looks like **Service create failures** with messages about **no available cluster IP**. Some clusters use **automatic** allocation only; advanced setups may discuss **IPAM** components or **dual-stack** secondary ranges. **Headless** Services (`clusterIP: None`) **do not** consume a routable ClusterIPâ€”important when counting address usage.

**Prerequisites:** [2.5.1 Service](../01-service/README.md).

## Flow of this lesson

```
  API server service CIDR
              â”‚
              â–¼
  Allocator assigns free ClusterIP per Service
              â”‚
              â–¼
  kube-proxy / CNI maps VIP â†’ endpoints
```

**Say:**

When **thousands** of Services exist, IPAM and **EndpointSlice** cardinalityâ€”not raw YAMLâ€”become the bottleneck.

## Learning objective

- Explain where **ClusterIP** addresses come from at a high level.
- Relate **headless** Services to **no ClusterIP consumption**.
- Use inspect output to correlate **Services** and **EndpointSlices** for address planning discussions.

## Why this matters

â€œCannot allocate ClusterIPâ€ during a hot migration is a **platform** incidentâ€”expanding CIDRs is painful.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/part-2-concepts/2.5-services-load-balancing-and-networking/01-service-clusterip-allocation" 2>/dev/null || cd .
```

## Step 1 â€” Apply notes ConfigMap

**What happens when you run this:**

Allocation teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-5-11-service-clusterip-allocation-notes.yaml
```

**Expected:** ConfigMap `2-5-11-service-clusterip-allocation-notes` in `kube-system` when allowed.

---

## Step 2 â€” Run inspect script

**What happens when you run this:**

Lists **Services** and **EndpointSlices** to ground allocation discussion in live data.

**Run:**

```bash
bash scripts/inspect-2-5-11-service-clusterip-allocation.sh
```

**Expected:** Script completes; Service and EndpointSlice listing succeeds.

## Video close â€” fast validation

```bash
bash scripts/inspect-2-5-11-service-clusterip-allocation.sh
```

## Troubleshooting

- **`range is full` errors** â†’ grow **service-cluster-ip-range** (major change) or delete stale Services
- **Duplicate IP panic** â†’ rare corruptionâ€”platform vendor runbook
- **Headless counted wrong** â†’ `clusterIP: None`â€”verify with **`kubectl get svc -o wide`**
- **Dual-stack needs two ranges** â†’ IPv4 and IPv6 CIDR both sized for growth
- **Static ClusterIP conflicts** â†’ manual **`clusterIP`** field clashes with allocator
- **`Forbidden` notes** â†’ offline only

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-2-5-11-service-clusterip-allocation.sh` | Service + EndpointSlice listing |
| `yamls/2-5-11-service-clusterip-allocation-notes.yaml` | Notes ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Exhaustion, conflicts, REST mapping |

## Cleanup

```bash
kubectl delete configmap 2-5-11-service-clusterip-allocation-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.5.12 Service Internal Traffic Policy](01-service-internal-traffic-policy/README.md)
