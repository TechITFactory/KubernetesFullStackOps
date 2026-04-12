# Proxies in Kubernetes — teaching transcript

## Intro

**Kubernetes** **has** **several** **“proxy”** **concepts**: **`kubectl proxy`** **(local** **HTTP** **to** **apiserver)**, **apiserver** **proxy** **subresources** **to** **Pods**/**Services**/**nodes**, **kube-proxy** **(Service** **dataplane)**, **and** **HTTP** **proxies** **in** **client** **environments**. **Confusing** **them** **breaks** **debugging** **sessions** **fast**. **This** **lesson** **maps** **each** **to** **its** **layer** **and** **security** **boundary**.

**Prerequisites:** [2.11.14 Traces for Kubernetes system components](../14-traces-for-kubernetes-system-components/README.md); [2.11.5 Cluster networking](../05-cluster-networking/README.md).

## Flow of this lesson

```
  Client tooling (kubectl proxy, HTTP_PROXY env)
              │
              ▼
  apiserver proxy subresources (pods, services, nodes)
              │
              ▼
  kube-proxy implements Service VIP reachability
```

**Say:**

**I** **explicitly** **say** **“kube-proxy** **is** **not** **kubectl** **proxy”** **in** **the** **first** **minute**—**it** **prevents** **weeks** **of** **student** **confusion**.

## Learning objective

- Contrast **`kubectl proxy`** **with** **kube-proxy** **DaemonSet** **behavior**.
- Name **when** **apiserver** **proxy** **URLs** **are** **appropriate** **for** **debugging**.

## Why this matters

**Mis-routed** **corporate** **`HTTP_PROXY`** **env** **vars** **break** **`kubectl`** **in** **ways** **that** **look** **like** **RBAC** **failures**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/11-cluster-administration/15-proxies-in-kubernetes" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-11-15-proxies-in-kubernetes-notes.yaml
kubectl get cm -n kube-system 2-11-15-proxies-in-kubernetes-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-11-15-proxies-in-kubernetes-notes`** when allowed.

---

## Step 2 — kube-proxy and Services (read-only)

**What happens when you run this:**

**Shows** **kube-proxy** **(or** **replacement)** **Pods** **and** **Service** **cluster** **IPs** **for** **discussion**.

**Run:**

```bash
kubectl get pods -n kube-system 2>/dev/null | grep -i proxy | head -n 10 || true
kubectl get svc kubernetes -o wide 2>/dev/null || true
kubectl explain service.spec.clusterIP 2>/dev/null | head -n 15 || true
```

**Expected:** **kube-proxy** **lines** **or** **empty**; **`kubernetes`** **Service**; **explain** **snippet**.

## Video close — fast validation

```bash
kubectl get svc -A 2>/dev/null | head -n 12 || true
```

## Troubleshooting

- **No** **kube-proxy** **pod** → **CNI** **implements** **Services** **or** **managed** **dataplane**
- **`kubectl proxy` hangs** → **local** **firewall** **or** **auth** **plugin**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-11-15-proxies-in-kubernetes-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-11-15-proxies-in-kubernetes-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.11.16 API Priority and Fairness](../16-api-priority-and-fairness/README.md)
