# 2.5 Services, Load Balancing, and Networking â€” teaching transcript

## Intro

Workloads alone are not reachable at a **stable** address: **Services** provide a **virtual ClusterIP**, **ports**, and **DNS names** that the data plane (traditionally **kube-proxy** with iptables or IPVS, or eBPF replacements) load-balances to **ready** Pod IPs. **Ingress** layers **HTTP/HTTPS** host and path rules on top of Services; an **Ingress controller** must run in the cluster to implement those rules. The **Gateway API** generalizes that pattern with **Gateway**, **GatewayClass**, and **route** objects for implementations like Envoy Gateway or others. **EndpointSlices** scale endpoint tracking beyond the older **Endpoints** object. **NetworkPolicy** restricts which flows the **CNI** allowsâ€”without a supporting CNI, policies are ignored. **Cluster DNS** (typically **CoreDNS**) resolves **`*.svc.cluster.local`** for Services and Pod DNS. This module moves from **ClusterIP** outward through exposure APIs, discovery, and policy.

**Prerequisites:** [Part 2 entry check](../README.md#prerequisites-met-read-this-before-21); complete [2.4.3.1 Deployments](../2.4-workloads/2.4.3-workload-management/2.4.3.1-deployments/README.md) before Services so **labels and readiness** are familiar.

**Tested-on note:** ClusterIP demo uses `nginx:1.27` in namespace **`svc-demo`** â€” see [`KUBERNETES_VERSION_MATRIX.md`](../../KUBERNETES_VERSION_MATRIX.md).

## Flow of this lesson

```
  ClusterIP Service (stable VIP + DNS)
              â”‚
              â–¼
  Ingress / Gateway API (L7 routes â†’ Service backends)
              â”‚
              â–¼
  EndpointSlices (pod IPs behind Services)
              â”‚
              â”œâ”€â”€â–º Cluster DNS (names â†’ ClusterIP or headless)
              â”‚
              â””â”€â”€â–º NetworkPolicy (allow/deny between workloads)
```

**Say:**

I teach **Service + readiness + endpoints** first; Ingress without endpoints is an empty shell. DNS is the glue; NetworkPolicy is the guardrailâ€”order may vary but dependencies look like this.

## Learning objective

- Name the roles of **Service**, **Ingress/Gateway**, **EndpointSlices**, **DNS**, and **NetworkPolicy** in cluster networking.
- Run the module **quick validation** commands after labs.

## Why this matters

â€œWorks from inside the cluster but not from Ingressâ€ and â€œService has no endpointsâ€ are everyday incidentsâ€”this module separates **which layer** broke.

## Children

- [2.5.1 Service](01-service/README.md) â€” **transcript + `svc-demo` lab + verify**
- [2.5.2 Ingress](02-ingress/README.md)
- [2.5.3 Ingress Controllers](02-ingress-controllers/README.md)
- [2.5.4 Gateway API](04-gateway-api/README.md)
- [2.5.5 EndpointSlices](05-endpointslices/README.md)
- [2.5.6 Network Policies](06-network-policies/README.md)
- [2.5.7 DNS for Services and Pods](07-dns-for-services-and-pods/README.md)
- [2.5.8 IPv4/IPv6 Dual-Stack](08-ipv4-ipv6-dual-stack/README.md)
- [2.5.9 Topology Aware Routing](09-topology-aware-routing/README.md)
- [2.5.10 Networking on Windows](10-networking-on-windows/README.md)
- [2.5.11 Service ClusterIP Allocation](01-service-clusterip-allocation/README.md)
- [2.5.12 Service Internal Traffic Policy](01-service-internal-traffic-policy/README.md)

## Module wrap â€” quick validation

**What happens when you run this:** Read-only snapshot of Services, slices, policies, and DNS pods.

**Say:**

I run this after **2.5.1** and again after **NetworkPolicy** labs to show how object counts changed.

```bash
kubectl get svc,ing -A 2>/dev/null | head -n 40
kubectl get endpointslices -A 2>/dev/null | head -n 20
kubectl get networkpolicy -A 2>/dev/null | head -n 20 || true
kubectl get pods -n kube-system -l k8s-app=kube-dns 2>/dev/null || kubectl get pods -n kube-system | grep -i coredns || true
```

## Troubleshooting

- **Empty `ing` rows** â†’ normal without Ingress objects or CRD-less cluster
- **`endpointslices` not found** â†’ very old server; upgrade or use `kubectl get endpoints`
- **NetworkPolicy list empty** â†’ policies not applied or API disabled
- **No CoreDNS pods** â†’ vendor DNS name differs; grep `kube-system` for `dns`
- **RBAC cannot list `-A`** â†’ narrow to namespaces you teach in
- **`svc-demo` missing** â†’ run [2.5.1](01-service/README.md) lab first

## Next module

[2.6 Storage](../2.6-storage/README.md)
