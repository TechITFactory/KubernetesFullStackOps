# 2.5.6 Network Policies — teaching transcript

## Intro

**NetworkPolicy** selects **Pods** by labels and defines **ingress** and/or **egress** rules: allowed **peers** (pod selectors, namespace selectors, CIDR blocks) and **ports**. Policies are **additive only in the sense you define**—many CNIs implement a **default allow-all** until the first policy touches a Pod, then **only** what policies permit (**default deny**) for that Pod; **confirm semantics with your CNI documentation** because behavior varies slightly. Policies require a **CNI that enforces** them (Calico, Cilium, Antrea, …); without enforcement, `kubectl apply` succeeds but **nothing** changes on the wire. A classic footgun is **locking out DNS** by forgetting an **egress** rule to **kube-system** **DNS** Service or **CoreDNS** pods—**Pods** then fail name resolution.

**Prerequisites:** [2.5.5 EndpointSlices](../2.5.5-endpointslices/README.md); [2.5.1 Service](../2.5.1-service/README.md) for Service/label vocabulary.

## Flow of this lesson

```
  NetworkPolicy (pod selector + ingress/egress rules)
              │
              ▼
  CNI datapath enforces (if supported)
              │
              ▼
  Allowed flows only; DNS egress often required explicitly
```

**Say:**

I draw **default deny** on the whiteboard the moment the first policy appears in a namespace.

## Learning objective

- Describe **NetworkPolicy** rule structure at a high level.
- State the requirement for **CNI support** to enforce policies.
- Warn about **DNS egress** and **kube-system** paths.

## Why this matters

Misapplied policies cause “app works in dev CNI, dead in prod CNI” and mysterious **DNS** failures.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/part-2-concepts/2.5-services-load-balancing-and-networking/2.5.6-network-policies" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

In-cluster policy teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-5-6-network-policies-notes.yaml
```

**Expected:** ConfigMap `2-5-6-network-policies-notes` in `kube-system` when RBAC allows.

---

## Step 2 — Inspect policies and Services

**What happens when you run this:**

Script lists **NetworkPolicy** objects (may be empty) and **Services** for context.

**Run:**

```bash
bash scripts/inspect-2-5-6-network-policies.sh
```

**Expected:** Script completes; NetworkPolicy list may be empty on fresh clusters.

## Video close — fast validation

```bash
bash scripts/inspect-2-5-6-network-policies.sh
```

## Troubleshooting

- **Policy applied, no effect** → CNI does not enforce; check provider matrix
- **Everything breaks after first policy** → implicit **default deny**—add explicit **allow** rules
- **DNS timeouts** → allow **egress** to **CoreDNS** (UDP/TCP 53) or matching namespace/pod selectors
- **Cross-namespace** → verify **namespaceSelector** and **podSelector** together
- **Host network / kube-proxy paths** → some traffic bypasses Pod network—read CNI notes
- **`Forbidden` apply** → RBAC; teach from YAML without kube-system write

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-2-5-6-network-policies.sh` | Policy + Service inventory |
| `yamls/2-5-6-network-policies-notes.yaml` | Notes ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Default-allow myths, DNS blocks, CNI gaps |

## Cleanup

```bash
kubectl delete configmap 2-5-6-network-policies-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.5.7 DNS for Services and Pods](2.5.7-dns-for-services-and-pods/README.md)
