# 2.11 Cluster administration — teaching transcript

## Intro

**Cluster** **administration** **covers** **node** **lifecycle** **(shutdowns**, **swap**, **autoscaling)**, **trust** **(certificates)**, **data** **plane** **networking**, **observability** **(metrics**, **logs**, **traces)**, **admission** **webhooks**, **resource** **plugins**, **logging** **architecture**, **control-plane** **compatibility**, **proxies**, **API** **Priority** **and** **Fairness**, **addons**, **and** **coordinated** **leader** **election**. These topics sit **next** **to** **workloads** **and** **security**: **you** **already** **know** **Pods** **and** **RBAC**—here **the** **focus** **is** **platform** **SRE** **surfaces** **and** **how** **to** **inspect** **them** **read-only** **with** **`kubectl`**.

**Prerequisites:** [2.10 Scheduling, preemption and eviction](../10-scheduling-preemption-and-eviction/README.md); [2.8 Security](../08-security/README.md) for **admission** **and** **webhook** **context**.

## Flow of this lesson

```
  Nodes healthy (shutdowns, swap, scale)
              │
              ▼
  Trust + networking (certs, CNI/Services)
              │
              ▼
  Observability stack (metrics, logs, traces)
              │
              ▼
  Control plane policy (webhooks, DRA admin, APF, compatibility)
              │
              ▼
  Platform glue (proxies, addons, leader election)
```

**Say:**

I **group** **incidents** **by** **“node”**, **“control** **plane”**, **and** **“data** **plane”**—**this** **module** **maps** **cleanly** **to** **those** **three** **buckets**.

## Learning objective

- Use **`kubectl`** **and** **repo** **inspect** **scripts** **to** **snapshot** **cluster** **health** **without** **mutating** **state**.
- Name **where** **certificates**, **webhooks**, **APF**, **and** **leader** **leases** **show** **up** **in** **the** **API**.

## Why this matters

**Production** **clusters** **fail** **at** **boundaries** **between** **components**—**admin** **lessons** **teach** **you** **which** **dial** **to** **read** **before** **you** **turn** **it**.

## Children (suggested order)

1. [2.11.1 Node shutdowns](01-node-shutdowns/README.md)
2. [2.11.2 Swap memory management](02-swap-memory-management/README.md)
3. [2.11.3 Node autoscaling](03-node-autoscaling/README.md)
4. [2.11.4 Certificates](04-certificates/README.md)
5. [2.11.5 Cluster networking](05-cluster-networking/README.md)
6. [2.11.6 Observability](06-observability/README.md)
7. [2.11.7 Admission webhook good practices](07-admission-webhook-good-practices/README.md)
8. [2.11.8 Good practices for dynamic resource allocation as a cluster admin](08-good-practices-for-dynamic-resource-allocation-as-a-cluster-admin/README.md)
9. [2.11.9 Logging architecture](09-logging-architecture/README.md)
10. [2.11.10 Compatibility version for Kubernetes control plane components](10-compatibility-version-for-kubernetes-control-plane-components/README.md)
11. [2.11.11 Metrics for Kubernetes system components](11-metrics-for-kubernetes-system-components/README.md)
12. [2.11.12 Metrics for Kubernetes object states](12-metrics-for-kubernetes-object-states/README.md)
13. [2.11.13 System logs](13-system-logs/README.md)
14. [2.11.14 Traces for Kubernetes system components](14-traces-for-kubernetes-system-components/README.md)
15. [2.11.15 Proxies in Kubernetes](15-proxies-in-kubernetes/README.md)
16. [2.11.16 API Priority and Fairness](16-api-priority-and-fairness/README.md)
17. [2.11.17 Installing addons](17-installing-addons/README.md)
18. [2.11.18 Coordinated leader election](18-coordinated-leader-election/README.md)

## Module wrap — quick validation

**What happens when you run this:** **Nodes**, **kube-system** **footprint**, **and** **client**/**server** **version** **skew** **hint**.

**Say:**

Before **2.11.4**, I **pull** **pending** **CSRs** **so** **the** **rotation** **story** **has** **a** **concrete** **object** **on** **screen**.

```bash
kubectl get nodes -o wide 2>/dev/null | head -n 15 || true
kubectl get pods -n kube-system 2>/dev/null | head -n 20 || true
kubectl version -o yaml 2>/dev/null | head -n 30 || true
```

## Troubleshooting

- **`Forbidden` on many reads** → **use** **read-only** **break-glass** **context** **or** **teach** **from** **slides** **only**
- **Empty** **kube-system** **on** **managed** **K8s** → **provider** **moved** **components** **off** **cluster** **visibility**
- **Wrong** **cluster** → **`kubectl config current-context`**

## Next

[2.12 Windows in Kubernetes](../12-windows-in-kubernetes/README.md)
