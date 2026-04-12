# Service Internal Traffic Policy — teaching transcript

## Intro

**`internalTrafficPolicy`** on a **Service** controls how **cluster-internal** traffic is load-balanced across endpoints. **`Cluster`** (default) uses **all** ready endpoints cluster-wide—classic behavior. **`Local`** restricts routing to endpoints **on the same node** as the client (when used with patterns like **externalTrafficPolicy: Local** on **NodePort/LoadBalancer**, traffic **health** and **source IP** semantics also shift—read the combined docs for your case). **Misunderstanding “Local”** causes **black holes** when a node has **no local endpoints** but clients still land there via **external** paths. **kube-proxy** mode and **CNI** features affect observability—always **`kubectl get svc -o yaml`** and **`kubectl explain service.spec.internalTrafficPolicy`** on your version.

**Prerequisites:** [2.5.1 Service](../01-service/README.md); [2.5.5 EndpointSlices](../05-endpointslices/README.md).

## Flow of this lesson

```
  internalTrafficPolicy: Cluster
        → any ready endpoint in cluster

  internalTrafficPolicy: Local
        → prefer / restrict to node-local endpoints (datapath dependent)
```

**Say:**

I pair this field with **externalTrafficPolicy** when teaching **LoadBalancer** health—easy to conflate them.

## Learning objective

- Contrast **`Cluster`** and **`Local`** **internalTrafficPolicy** semantics at a high level.
- Warn about **no local endpoint** failure modes with **Local**.
- Use inspect script output to spot the field on supported clusters.

## Why this matters

Switching to **Local** for latency without enough **per-node** replicas drops traffic on some nodes—production outages.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/2.5-services-load-balancing-and-networking/01-service-internal-traffic-policy" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Internal traffic policy notes.

**Run:**

```bash
kubectl apply -f yamls/2-5-12-service-internal-traffic-policy-notes.yaml
```

**Expected:** ConfigMap `2-5-12-service-internal-traffic-policy-notes` in `kube-system` when allowed.

---

## Step 2 — Inspect Services and policy field

**What happens when you run this:**

Script lists Services; **internalTrafficPolicy** appears in YAML on supported versions.

**Run:**

```bash
bash scripts/inspect-2-5-12-service-internal-traffic-policy.sh
```

**Expected:** Services list; internal traffic policy visible when API server supports it.

## Video close — fast validation

```bash
bash scripts/inspect-2-5-12-service-internal-traffic-policy.sh
```

## Troubleshooting

- **Traffic drops after Local** → not every node runs a backend—add **DaemonSet** or revert policy
- **Health probes fail on cloud LB** → **externalTrafficPolicy: Local** interaction—separate lesson path
- **Field ignored** → old **Kubernetes** version—upgrade or drop field
- **kube-proxy iptables vs IPVS** → subtle behavioral differences—vendor matrix
- **Confused with topology hints** → see [2.5.9](../09-topology-aware-routing/README.md)
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-2-5-12-service-internal-traffic-policy.sh` | Service listing / policy visibility |
| `yamls/2-5-12-service-internal-traffic-policy-notes.yaml` | Notes ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Local vs Cluster surprises, health loops |

## Cleanup

```bash
kubectl delete configmap 2-5-12-service-internal-traffic-policy-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.6 Storage](../../2.6-storage/README.md)
