# DNS for Services and Pods — teaching transcript

## Intro

Cluster **DNS** (almost always **CoreDNS** today, sometimes still referenced as **kube-dns**) answers queries from Pods for **Service** names: **`my-svc.my-ns.svc.cluster.local`**, short names **`my-svc`** or **`my-svc.my-ns`** depending on **search domains** in **`/etc/resolv.conf`**. The **`ndots`** option affects when the resolver tries absolute vs search-relative names—misunderstanding it causes “works with FQDN, fails with short name.” **Headless** Services return **A/AAAA** records for **ready** Pod endpoints. **Pod DNS policies** (`Default`, `ClusterFirst`, `ClusterFirstWithHostNet`, `None`) change whether Pod DNS uses the cluster server or host resolvers. Upstream **forwarding** and **stub domains** are configured in **CoreDNS** `Corefile`—loops or corporate resolver blocks show up as **intermittent NXDOMAIN** or **timeouts**.

**Prerequisites:** [2.5.1 Service](../01-service/README.md).

## Flow of this lesson

```
  Pod → cluster DNS Service IP (usually kube-dns)
              │
              ▼
  CoreDNS Corefile (plugins: kubernetes, forward, …)
              │
              ▼
  Answers for .svc.cluster.local + optional upstream
```

**Say:**

When **curl** fails with “Could not resolve host,” I **`cat /etc/resolv.conf`** inside the client Pod before blaming the app.

## Learning objective

- Explain **Service DNS** naming under **`cluster.local`** (and cluster domain customization).
- Relate **search list** and **ndots** to short-name resolution behavior.
- Locate **CoreDNS** pods in **kube-system** and describe their role.

## Why this matters

Half of mesh and microservice outages are **DNS**—especially after **NetworkPolicy** changes or **split-horizon** corporate DNS.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/2.5-services-load-balancing-and-networking/07-dns-for-services-and-pods" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

DNS teaching notes in **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-5-7-dns-for-services-and-pods-notes.yaml
```

**Expected:** ConfigMap `2-5-7-dns-for-services-and-pods-notes` created when allowed.

---

## Step 2 — Run inspect script

**What happens when you run this:**

Aggregates DNS-related cluster views—implementation-specific.

**Run:**

```bash
bash scripts/inspect-2-5-7-dns-for-services-and-pods.sh
```

**Expected:** CoreDNS/kube-dns pods visible in `kube-system`; script completes.

## Video close — fast validation

```bash
kubectl get pods -n kube-system -l k8s-app=kube-dns 2>/dev/null || kubectl get pods -n kube-system | grep -i coredns
bash scripts/inspect-2-5-7-dns-for-services-and-pods.sh
```

## Troubleshooting

- **CoreDNS CrashLoop** → **Corefile** syntax or **forward** plugin to broken upstream
- **NXDOMAIN for valid Service** → wrong namespace in name; check **search** path
- **Slow lookups** → **ndots:5** causes search fan-out—use FQDN in hot paths or tune
- **HostNetwork pods** → **dnsPolicy** may bypass cluster DNS—explicitly set
- **NetworkPolicy blocks UDP/TCP 53** → allow egress to DNS Service ([2.5.6](../06-network-policies/README.md))
- **External name confusion** → **ExternalName** Service returns **CNAME**—client must follow

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-2-5-7-dns-for-services-and-pods.sh` | DNS-related inventory |
| `yamls/2-5-7-dns-for-services-and-pods-notes.yaml` | Notes ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Loops, upstream, search path mistakes |

## Cleanup

```bash
kubectl delete configmap 2-5-7-dns-for-services-and-pods-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.5.8 IPv4/IPv6 Dual-Stack](08-ipv4-ipv6-dual-stack/README.md)
