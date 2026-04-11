# 2.5.8 IPv4/IPv6 Dual-Stack — teaching transcript

## Intro

**Dual-stack** Kubernetes assigns both **IPv4** and **IPv6** addresses to **Pods** and **Services** when the control plane, **CNI**, and **node** networking are configured for it. On **Services**, **`ipFamilies`** and **`ipFamilyPolicy`** (`SingleStack`, `PreferDualStack`, `RequireDualStack`) control whether one or two **clusterIPs** are allocated; the **`clusterIPs`** field can hold multiple entries. **EndpointSlices** use **addressType** per slice—IPv4 and IPv6 backends may appear as **separate** slices. If the cluster is **IPv4-only**, manifests with **RequireDualStack** fail admission or Services stay single-stack—always **`kubectl get svc kubernetes -o jsonpath='{.spec.clusterIPs}'`** on a real cluster before teaching guarantees.

**Prerequisites:** [2.5.7 DNS](../2.5.7-dns-for-services-and-pods/README.md); [2.5.5 EndpointSlices](../2.5.5-endpointslices/README.md) helpful.

## Flow of this lesson

```
  Cluster dual-stack enabled (API + nodes + CNI)
              │
              ▼
  Service ipFamilies + ipFamilyPolicy
              │
              ▼
  clusterIPs[] + EndpointSlices (IPv4 / IPv6)
```

**Say:**

Dual-stack is a **platform** property first; YAML second.

## Learning objective

- Explain **`ipFamilies`**, **`ipFamilyPolicy`**, and **`clusterIPs`** on Services.
- Relate dual-stack Services to **EndpointSlice** **addressType**.
- Validate cluster capability with **`kubectl get svc kubernetes`**.

## Why this matters

Silent **IPv6-only** breakages appear when apps assume **IPv4** literals or when load balancers hand out **AAAA** records without path validation.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/part-2-concepts/2.5-services-load-balancing-and-networking/2.5.8-ipv4-ipv6-dual-stack" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Dual-stack notes for narration.

**Run:**

```bash
kubectl apply -f yamls/2-5-8-ipv4-ipv6-dual-stack-notes.yaml
kubectl get cm -n kube-system 2-5-8-ipv4-ipv6-dual-stack-notes -o name
```

**Expected:** ConfigMap present in `kube-system` when permitted.

---

## Step 2 — Inspect default Service cluster IPs

**What happens when you run this:**

**`kubernetes` default Service** shows how apiserver is exposed inside the cluster—**one or two** IPs depending on configuration.

**Run:**

```bash
kubectl get svc kubernetes -o jsonpath='{.spec.clusterIPs}' 2>/dev/null; echo
```

**Expected:** JSON array of IPs; dual-stack shows two entries only when cluster supports it.

## Video close — fast validation

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name} {.status.addresses[*].type}{"\n"}{end}' | head -n 10
kubectl get svc -A -o custom-columns=NAME:.metadata.name,IPS:.spec.clusterIPs --no-headers 2>/dev/null | head -n 15
```

## Troubleshooting

- **`RequireDualStack` rejected** → cluster single-stack; change policy or enable dual-stack
- **Pods IPv6-only, app IPv4** → app bind address or **happy eyeballs** issues
- **Slice addressType mismatch** → CNI not programming both families on endpoints
- **DNS AAAA without route** → clients try IPv6 first—validate end-to-end
- **kube-proxy mode differences** → iptables vs IPVS vs eBPF—vendor docs for dual-stack
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-5-8-ipv4-ipv6-dual-stack-notes.yaml` | Notes ConfigMap |
| `yamls/failure-troubleshooting.yaml` | ipFamilyPolicy mistakes, CNI skew |

## Cleanup

```bash
kubectl delete configmap 2-5-8-ipv4-ipv6-dual-stack-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.5.9 Topology Aware Routing](2.5.9-topology-aware-routing/README.md)
