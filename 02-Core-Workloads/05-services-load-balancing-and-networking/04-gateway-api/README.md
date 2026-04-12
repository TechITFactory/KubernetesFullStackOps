# Gateway API — teaching transcript

## Intro

The **Gateway API** is a family of CRDs that generalize north-south routing beyond the Ingress model. **GatewayClass** declares an implementation (“who programs the datapath”). **Gateway** requests **listeners** (addresses, ports, TLS). **HTTPRoute**, **GRPCRoute**, and related route types attach to a Gateway and specify **backendRefs** (often **Services**) with richer **matches**, **filters**, and **policy** extension points than classic Ingress. You must install a **compatible controller** (for example Envoy Gateway, ingress-nginx Gateway API mode, or others)—**`kubectl get gateway`** returns nothing useful until CRDs and a controller exist. This coexists with **Ingress** during migration; many clusters run both for years.

**Prerequisites:** [2.5.3 Ingress Controllers](../02-ingress-controllers/README.md).

## Flow of this lesson

```
  GatewayClass (implementation)
              │
              ▼
  Gateway (listeners, addresses)
              │
              ▼
  HTTPRoute / GRPCRoute → backendRefs (Services)
```

**Say:**

I map **Gateway** to “load balancer intent” and **HTTPRoute** to “URL routing rules”—naming helps Ingress veterans.

## Learning objective

- Name **GatewayClass**, **Gateway**, and **HTTPRoute** roles.
- Discover Gateway API **CRDs** with `kubectl api-resources`.
- Explain that a **controller implementation** must be installed for behavior.

## Why this matters

Greenfield platforms increasingly standardize on Gateway API; misinstalled CRDs without a controller produces silent no-op configs.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/2.5-services-load-balancing-and-networking/04-gateway-api" 2>/dev/null || cd .
```

## Step 1 — Apply notes and confirm ConfigMap

**What happens when you run this:**

Notes land in **kube-system** when permitted.

**Run:**

```bash
kubectl apply -f yamls/2-5-4-gateway-api-notes.yaml
kubectl get cm -n kube-system 2-5-4-gateway-api-notes -o name
```

**Expected:** ConfigMap `2-5-4-gateway-api-notes` in `kube-system`.

---

## Step 2 — Discover Gateway-related API resources

**What happens when you run this:**

**grep** filters `api-resources` for Gateway family kinds—often **empty** on minimal clusters.

**Say:**

Empty grep means “install CRDs + controller,” not “feature disabled in Kubernetes core.”

**Run:**

```bash
kubectl api-resources 2>/dev/null | grep -i gateway || true
```

**Expected:** Lines such as `gateways.gateway.networking.k8s.io` when installed; otherwise no output.

## Video close — fast validation

```bash
kubectl api-resources 2>/dev/null | grep -iE 'gateway|grpcroute|httproute' || true
kubectl get gateway -A 2>/dev/null || true
```

## Troubleshooting

- **CRDs missing** → install Gateway API bundle + pick an implementation chart
- **Gateway `Programmed=False`** → controller logs; check **GatewayClass** reference
- **HTTPRoute not attached** → **parentRefs** namespace and section names must match **Gateway** listeners
- **BackendRef refused** → cross-namespace refs need **ReferenceGrant** (policy object)
- **Conflicts with Ingress** → separate **addresses** or shared LB—plan with platform team
- **`Forbidden` kube-system** → skip apply; teach from git

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-5-4-gateway-api-notes.yaml` | Notes ConfigMap |
| `yamls/failure-troubleshooting.yaml` | CRD gaps, listener conflicts, backendRef failures |

## Cleanup

```bash
kubectl delete configmap 2-5-4-gateway-api-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.5.5 EndpointSlices](05-endpointslices/README.md)
