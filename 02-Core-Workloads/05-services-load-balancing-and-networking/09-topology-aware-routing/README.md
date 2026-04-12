# Topology Aware Routing — teaching transcript

## Intro

**Topology-aware routing** steers Service traffic toward endpoints **closer** in **topology**—zones, regions, or nodes—when possible to cut **cross-AZ** charges and latency. Kubernetes has evolved fields and hints across releases (**`service.kubernetes.io/topology-aware-hints`**, **`trafficDistribution`** on **Service**, relationship to **EndpointSlice** **hints**). The precise field names and default behavior depend on **server version** and whether **kube-proxy** (or a replacement) honors hints—use **`kubectl explain service.spec`** on your cluster rather than memorizing one release snapshot. Even when hints exist, **insufficient endpoints in-zone** forces **fallback** to other zones; this is **preference**, not strict affinity.

**Prerequisites:** [2.5.5 EndpointSlices](../05-endpointslices/README.md); [2.5.1 Service](../01-service/README.md).

## Flow of this lesson

```
  Nodes labeled (topology.kubernetes.io/zone, …)
              │
              ▼
  EndpointSlice hints + Service trafficDistribution / annotations
              │
              ▼
  Datapath prefers same-zone endpoints when healthy
```

**Say:**

I correlate **node labels** with **EndpointSlice** output—if zones are unlabeled, topology routing cannot work.

## Learning objective

- Describe the goal: **prefer local topology** for Service backends.
- Use **`kubectl explain`** to find **Service** fields available on your API server.
- Relate behavior to **EndpointSlices** and **kube-proxy** (or datapath) support.

## Why this matters

Surprise **cross-zone** bills after enabling “smart” routing usually mean **hints ignored** or **imbalanced** replica placement—not Kubernetes magic.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/2.5-services-load-balancing-and-networking/09-topology-aware-routing" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Topology routing notes.

**Run:**

```bash
kubectl apply -f yamls/2-5-9-topology-aware-routing-notes.yaml
kubectl get cm -n kube-system 2-5-9-topology-aware-routing-notes -o name
```

**Expected:** ConfigMap `2-5-9-topology-aware-routing-notes` in `kube-system`.

---

## Step 2 — Explain Service spec fields (version-dependent)

**What happens when you run this:**

Prints the top of **`kubectl explain`** for **`trafficDistribution`** or falls back to **`service.spec`**.

**Run:**

```bash
kubectl explain service.spec.trafficDistribution 2>/dev/null | head -n 15 || kubectl explain service.spec 2>/dev/null | head -n 20
```

**Expected:** Field documentation for your server version (names shifted across releases).

## Video close — fast validation

```bash
kubectl get svc -A -o wide 2>/dev/null | head -n 20
kubectl get endpointslices -A 2>/dev/null | head -n 15
```

## Troubleshooting

- **No effect after setting annotations** → kube-proxy version or mode ignores hints
- **Uneven zone traffic** → not enough **ready** pods per zone—scale or fix PDBs
- **Missing topology labels** → label nodes **`topology.kubernetes.io/zone`**
- **Hints disabled globally** → feature gate or controller flag—check platform docs
- **Confusion with internal traffic policy** → see [2.5.12](../01-service-internal-traffic-policy/README.md) for **Local** semantics
- **Explain returns empty** → upgrade cluster or consult docs for your minor version

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-5-9-topology-aware-routing-notes.yaml` | Notes ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Label mismatches, kube-proxy expectations |

## Cleanup

```bash
kubectl delete configmap 2-5-9-topology-aware-routing-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.5.10 Networking on Windows](10-networking-on-windows/README.md)
