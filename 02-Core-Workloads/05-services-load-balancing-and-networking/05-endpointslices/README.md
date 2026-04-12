# EndpointSlices — teaching transcript

## Intro

**EndpointSlices** are the scalable successor to the v1 **Endpoints** object: the control plane shards backend **addresses** (Pod IPs, and sometimes other targets) across multiple **EndpointSlice** resources per Service. Slices carry **ports**, **addressType** (**IPv4**, **IPv6**, **FQDN**), **conditions** (ready, serving, terminating), and **topology** hints. Label **`kubernetes.io/service-name`** ties slices back to a **Service** name. **kube-proxy** and many CNIs consume EndpointSlices to program dataplane rules. You still see **Endpoints** for compatibility, but large Services hit **size limits** faster on the legacy object—slices are the API to learn for debugging **many** backends or **dual-stack** address sets.

**Prerequisites:** [2.5.1 Service](../01-service/README.md).

## Flow of this lesson

```
  Service selector + ready Pods
              │
              ▼
  EndpointSlice objects (sharded)
              │
              ▼
  kube-proxy / CNI programs dataplane from slices
```

**Say:**

When **Endpoints** looks fine but traffic is wrong, I compare **EndpointSlices** for **terminating** endpoints during rollouts.

## Learning objective

- Contrast **Endpoints** with **EndpointSlices** and explain sharding.
- List **EndpointSlices** for a namespace and relate labels to **Service** names.
- Mention **addressType** and dual-stack implications.

## Why this matters

Stale or missing slices after CNI upgrades show up as **asymmetric** load balancing—operators must know where the truth lives.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/2.5-services-load-balancing-and-networking/05-endpointslices" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Stores EndpointSlice teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-5-5-endpointslices-notes.yaml
kubectl get cm -n kube-system 2-5-5-endpointslices-notes -o name
```

**Expected:** ConfigMap `2-5-5-endpointslices-notes` in `kube-system`.

---

## Step 2 — List EndpointSlices cluster-wide

**What happens when you run this:**

Shows slices for Services that have **ready** backends—**svc-demo** helps if [2.5.1](../01-service/README.md) lab ran.

**Run:**

```bash
kubectl get endpointslices -A 2>/dev/null | head -n 20
```

**Expected:** Rows with **SERVICE** column (or NAME patterns) listing slices; may be sparse on empty clusters.

## Video close — fast validation

```bash
kubectl get endpointslices -A 2>/dev/null | head -n 25
kubectl get svc -A | head -n 15
```

## Troubleshooting

- **No EndpointSlices** → no Services with selectors and ready endpoints, or very old cluster
- **Slice count explosion** → many pods per Service—normal sharding; avoid `kubectl get endpoints` only
- **Dual-stack skew** → **addressType** IPv4 vs IPv6 slices mismatch—see [2.5.8](../08-ipv4-ipv6-dual-stack/README.md)
- **Terminating endpoints linger** → graceful shutdown / EndpointSlice **serving** conditions during rollout
- **Confusion with Endpoints** → compare **`kubectl get endpoints NAME`** vs **`kubectl get endpointslices -l kubernetes.io/service-name=NAME`**
- **`Forbidden`** → RBAC on **discovery.k8s.io** API group

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-5-5-endpointslices-notes.yaml` | Notes ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Endpoints vs slices, stale endpoints, dual-stack |

## Cleanup

```bash
kubectl delete configmap 2-5-5-endpointslices-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.5.6 Network Policies](06-network-policies/README.md)
