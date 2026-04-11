# 2.4.1.6 Pod Hostname — teaching transcript

## Intro

Inside the Pod, **`hostname`** defaults to the **Pod name** unless you set **`spec.hostname`**. **`spec.subdomain`** plus the cluster’s **`clusterDomain`** (commonly **`cluster.local`**) participates in **DNS** naming for **headless Services**: a Pod can be addressed as **`podname.subdomain.namespace.svc.cluster.local`** when the Service publishes **`subdomain`**-style records. **StatefulSet** goes further: stable pod names **`name-0`**, **`name-1`**, … combine with the **headless Service** name to give **per-replica DNS** like **`pod-0.service.namespace.svc.cluster.local`**—that is the identity pattern brokers and databases rely on.

**Prerequisites:** [2.4.1.5 Disruptions](../2.4.1.5-disruptions/README.md) recommended.

## Flow of this lesson

```
  spec.hostname (optional override)
  spec.subdomain + cluster DNS
        │
        ▼
  /etc/hosts + cluster DNS answers
        │
        ▼
  StatefulSet: stable pod-ordinal DNS via headless Service
```

**Say:**

Hostname is what `uname -n` shows; DNS is what other Pods use to dial you—do not confuse the two.

## Learning objective

- Explain default **hostname** versus **`spec.hostname`**.
- Relate **`subdomain`** and **cluster domain** to Pod DNS names.
- Connect **StatefulSet** ordinals to **stable FQDN** patterns.

## Why this matters

Misconfigured headless Services break **peer discovery** in clustered stateful apps—every Helm chart for Kafka or etcd assumes you understand this naming.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/part-2-concepts/2.4-workloads/2.4.1-pods/2.4.1.6-pod-hostname" 2>/dev/null || cd .
```

## Step 1 — Apply demo and read hostname

**What happens when you run this:**

The Pod starts; **`hostname`** inside reflects manifest defaults or overrides.

**Say:**

I compare **`kubectl get pod NAME -o jsonpath='{.spec.hostname}'`** mentally with **`exec hostname`**.

**Run:**

```bash
kubectl apply -f yamls/pod-hostname-demo.yaml
kubectl wait --for=condition=Ready pod/pod-hostname-demo --timeout=120s
kubectl exec pod/pod-hostname-demo -- hostname
```

**Expected:** Hostname output consistent with `hostname` / `subdomain` fields in the manifest.

---

## Step 2 — Inspect hosts file and wide view

**What happens when you run this:**

`/etc/hosts` inside the container often lists Pod IP and short names—useful for teaching **pause** container networking.

**Say:**

Cluster DNS still comes from **`resolv.conf`**; **`/etc/hosts`** is not the whole story.

**Run:**

```bash
kubectl get pod pod-hostname-demo -o wide
kubectl exec pod/pod-hostname-demo -- cat /etc/hosts | head
```

**Expected:** Pod IP and identity lines visible; `wide` shows cluster IP and node.

## Video close — fast validation

```bash
kubectl get pod pod-hostname-demo -o wide
kubectl exec pod/pod-hostname-demo -- cat /etc/hosts | head
```

## Troubleshooting

- **Hostname unexpected** → check **`spec.hostname`** and whether CRI overrides
- **DNS does not resolve peer** → verify **headless Service** and **subdomain** alignment; see [2.4.3.3 StatefulSets](../../2.4.3-workload-management/2.4.3.3-statefulsets/README.md)
- **`hostname` vs Pod metadata.name** → StatefulSet pods use **ordinal names**; explain to app owners
- **IPv6 dual-stack surprises** → `wide` and `/etc/hosts` may show multiple addresses
- **`exec` fails** → Pod not Ready or policy blocked
- **Wrong namespace** → prefix `-n` on all commands

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/pod-hostname-demo.yaml` | Hostname / subdomain demo |
| `yamls/failure-troubleshooting.yaml` | DNS and networking drills |

## Cleanup

```bash
kubectl delete -f yamls/pod-hostname-demo.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.1.7 Pod Quality of Service Classes](../2.4.1.7-pod-quality-of-service-classes/README.md)
