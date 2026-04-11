# 2.5.2 Ingress â€” teaching transcript

## Intro

An **Ingress** object describes **HTTP and HTTPS** routing rules: **hostnames**, **paths**, and **backend Services** (name + port). Ingress is **only configuration**â€”something in the cluster must **implement** it. That implementation is an **Ingress controller** ([2.5.3](02-ingress-controllers/README.md)), which typically watches Ingress resources, configures a reverse proxy (NGINX, Envoy, Traefik, â€¦), and obtains **external** connectivity via **LoadBalancer** or **NodePort** Services. **TLS** references **Secrets** containing certificates; **ingressClassName** (or legacy annotations) selects which controller reconciles the object. Without a matching controller, **`kubectl get ingress`** shows objects but **no traffic** flows.

**Prerequisites:** [2.5.1 Service](../01-service/README.md) so **Service backends** and **ports** are familiar.

## Flow of this lesson

```
  Ingress rules (host/path â†’ Service:port)
              â”‚
              â–¼
  Ingress controller (separate install)
              â”‚
              â–¼
  Data path to Pods (via Service endpoints)
```

**Say:**

I never debug Ingress YAML before confirming **endpoints exist** on the backend Service.

## Learning objective

- Describe **Ingress** as L7 routing configuration distinct from **ClusterIP**.
- Explain the need for an **Ingress controller** and **ingress class** selection.
- Relate **TLS** configuration to **Secret** references.

## Why this matters

â€œIngress created but 404 foreverâ€ usually means **no controller**, **wrong class**, or **backend Service** mismatchâ€”this lesson names those buckets.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/part-2-concepts/2.5-services-load-balancing-and-networking/02-ingress" 2>/dev/null || cd .
```

## Step 1 â€” Apply notes ConfigMap

**What happens when you run this:**

Stores teaching notes in **kube-system** when RBAC allows.

**Say:**

If **Forbidden**, open the YAML from git and narrate without applying.

**Run:**

```bash
kubectl apply -f yamls/2-5-2-ingress-notes.yaml
```

**Expected:** ConfigMap `2-5-2-ingress-notes` created or unchanged in `kube-system`.

---

## Step 2 â€” Run inspect script

**What happens when you run this:**

Lists Ingress across namespaces and related contextâ€”may be **empty** on a minimal cluster.

**Say:**

Empty **Ingress** is normal until you install a controller chart and apply a route manifest.

**Run:**

```bash
bash scripts/inspect-2-5-2-ingress.sh
```

**Expected:** Script completes; `kubectl get ingress -A` output shown (possibly empty).

## Video close â€” fast validation

```bash
bash scripts/inspect-2-5-2-ingress.sh
```

## Troubleshooting

- **Ingress exists, no routing** â†’ install or fix **Ingress controller**; check **ingressClassName**
- **`default backend` responses** â†’ path/host mismatch or Service port wrong
- **TLS errors** â†’ Secret namespace, key names, or cert SANs do not match **host**
- **502 from controller** â†’ **Endpoints** empty on backend Service
- **Webhook / admission errors** â†’ some controllers validate Ingress; check controller logs
- **`Forbidden` applying notes** â†’ skip kube-system apply; use local file

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-2-5-2-ingress.sh` | Cluster Ingress inventory |
| `yamls/2-5-2-ingress-notes.yaml` | In-cluster notes ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Class, backend Service, TLS mismatches |

## Cleanup

```bash
kubectl delete configmap 2-5-2-ingress-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.5.3 Ingress Controllers](02-ingress-controllers/README.md)
