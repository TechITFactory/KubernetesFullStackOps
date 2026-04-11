# 2.5.1 Service — teaching transcript

## Intro

A **ClusterIP Service** exposes a **stable virtual IP** inside the cluster and a **DNS name** of the form **`my-svc.my-ns.svc.cluster.local`**. The **Service `selector`** chooses Pods by labels; the control plane publishes **Endpoints** and **EndpointSlices** listing the **Pod IPs** that are **Ready**. The data path—**kube-proxy** on each node, or a CNI/eBPF implementation—forwards traffic destined to the ClusterIP to one of those backends. The Service **`port`** is what clients dial; **`targetPort`** is the **container port** (or name) on the Pod. **Readiness** matters: not-ready Pods are omitted from typical Service load balancing. **Headless** Services (`clusterIP: None`) skip the VIP and return Pod A records—covered with StatefulSets in [2.4.3.3 StatefulSet](../../2.4-workloads/2.4.3-workload-management/2.4.3.3-statefulsets/README.md); this lesson uses a **normal** ClusterIP.

**Prerequisites**

- [Part 2 prerequisites](../../README.md#prerequisites-met-read-this-before-21)
- [2.4.3.1 Deployments](../../2.4-workloads/2.4.3-workload-management/2.4.3.1-deployments/README.md) (pod template + labels)

## Learning objective

- Explain **ClusterIP** as a virtual IP and DNS name load-balanced to **ready** Pod IPs.
- Connect **Service `selector` → Endpoints / EndpointSlices → Pod IPs** with `kubectl get`.
- Distinguish **Service `port`** from **container `targetPort`**.

## Why this matters

“Service has no endpoints” is a top incident pattern: selector mismatch, pods not **Ready**, or wrong **namespace**. This lesson makes those checks **muscle memory**.

## Flow of this lesson

```
  Client Pod
      │
      ▼
  DNS: echo.svc-demo.svc.cluster.local → ClusterIP
      │
      ▼
  kube-proxy / datapath → EndpointSlice backends
      │
      ▼
  Ready Pod IPs : targetPort
```

**Say:**

If **Endpoints** is empty, I do not touch kube-proxy first—I fix **labels** or **readiness**.

## Concepts (short theory)

- **ClusterIP** is only reachable **inside** the cluster unless you add port-forward, Ingress, or Gateway.
- **NodePort** opens a high node port; **LoadBalancer** requests a cloud VIP—same selector model, different front door.

---

## Step 1 — Apply demo and confirm backends

**What happens when you run this:**

`service-clusterip-demo.yaml` creates **`svc-demo`**, a **2-replica** Deployment, and a **ClusterIP** Service selecting `app=echo`. **Endpoints** and **EndpointSlices** populate when Pods are **Ready**.

**Say:**

I read **`kubectl -n svc-demo get … endpoints echo`** aloud—**addresses** should list two pod IPs.

**Run:**

```bash
kubectl apply -f yamls/service-clusterip-demo.yaml
kubectl -n svc-demo rollout status deployment/echo --timeout=180s
kubectl -n svc-demo get svc,deploy,pods,endpoints echo
```

**Expected:** Service **CLUSTER-IP** assigned; Deployment available; two Pods **Running**/**Ready**; Endpoints show subset addresses.

---

## Step 2 — Optional curl from an in-cluster client

**What happens when you run this:**

A throwaway Pod resolves **FQDN** DNS and HTTP GETs the Service; exits after one request.

**Say:**

This proves **DNS + ClusterIP + routing** together—not just YAML on disk.

**Run:**

```bash
kubectl run curl-once -n svc-demo --rm -i --restart=Never --image=curlimages/curl:8.5.0 -- \
  curl -sS -o /dev/null -w "%{http_code}\n" http://echo.svc-demo.svc.cluster.local/
```

**Expected:** `200` (then the client pod exits).

---

## Step 3 — Verify script

**What happens when you run this:**

Automated checks for ClusterIP presence and backend count.

**Run:**

```bash
chmod +x scripts/verify-2-5-1-service-lesson.sh
./scripts/verify-2-5-1-service-lesson.sh
```

**Expected:** Script exits successfully.

## Troubleshooting

- **Endpoints empty** → `kubectl -n svc-demo get pods --show-labels`; match **Service spec.selector**
- **Pods not Ready** → `describe pod` for probes or crash reasons
- **Wrong HTTP code from curl** → check **targetPort** vs container **containerPort**
- **DNS NXDOMAIN** → wrong namespace in FQDN or CoreDNS down ([2.5.7](../2.5.7-dns-for-services-and-pods/README.md))
- **`Forbidden` applying demo** → RBAC; use namespace your user owns
- **Verify script fails** → partial apply; delete namespace and re-apply

## Video close — fast validation

**Say:**

I show **EndpointSlices** beside **Endpoints** so viewers see the modern API.

```bash
kubectl -n svc-demo get svc echo -o wide
kubectl -n svc-demo get endpoints echo -o yaml | head -n 40
kubectl get endpointslices -n svc-demo -l kubernetes.io/service-name=echo -o wide 2>/dev/null || true
```

## Optional asset (RBAC)

`yamls/2-5-1-service-notes.yaml` installs a **ConfigMap** in **`kube-system`** — only apply if your user may write that namespace (often **denied** on managed clusters). The runnable lab uses **`svc-demo`** only.

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/service-clusterip-demo.yaml` | Namespace + Deployment + ClusterIP Service |
| `scripts/verify-2-5-1-service-lesson.sh` | ClusterIP + backend count checks |
| `scripts/inspect-2-5-1-service.sh` | Broad `kubectl get svc` / EndpointSlice listing |
| `yamls/2-5-1-service-notes.yaml` | Optional kube-system notes (RBAC) |
| `yamls/failure-troubleshooting.yaml` | Empty endpoints, wrong types |

## Cleanup

```bash
kubectl delete -f yamls/service-clusterip-demo.yaml --ignore-not-found 2>/dev/null || true
kubectl delete configmap 2-5-1-service-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.5.2 Ingress](../2.5.2-ingress/README.md)
