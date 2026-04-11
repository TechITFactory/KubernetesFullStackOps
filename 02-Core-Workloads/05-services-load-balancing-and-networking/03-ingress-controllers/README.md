# 2.5.3 Ingress Controllers â€” teaching transcript

## Intro

The **Ingress API** is declarative; an **Ingress controller** is a **running** component that **watches** Ingress (and often related) objects and programs a **datapath**â€”commonly an in-cluster reverse proxy exposed via **Service** type **LoadBalancer** or **NodePort**. Examples include **ingress-nginx**, **Traefik**, **Contour**, **HAProxy Ingress**, and cloud-specific controllers. Controllers differ by **annotations**, **CRDs**, **admission webhooks**, and **certificate** automation (for example ACME). If **no controller** matches your **ingressClassName**, Ingress resources sit idle. **Validating admission webhooks** can reject bad Ingress YAML; **cert-manager** often sits beside the controller for TLS.

**Prerequisites:** [2.5.2 Ingress](../02-ingress/README.md).

## Flow of this lesson

```
  Helm/chart installs controller Deployment + Service + RBAC
              â”‚
              â–¼
  Controller watches Ingress objects
              â”‚
              â–¼
  Proxy config + external Service front door
```

**Say:**

Platform teams own **one** default Ingress class per cluster to avoid â€œwhich controller got this?â€ confusion.

## Learning objective

- Contrast the **Ingress resource** with the **controller** implementation.
- Name common controller options and how they obtain **external** reachability.
- Mention **webhooks** and **TLS** integration as operational concerns.

## Why this matters

Half of â€œIngress brokenâ€ tickets are **missing or mismatched controller**, not bad app YAML.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/part-2-concepts/2.5-services-load-balancing-and-networking/02-ingress-controllers" 2>/dev/null || cd .
```

## Step 1 â€” Apply notes ConfigMap

**What happens when you run this:**

In-cluster notes for controller concepts.

**Say:**

Managed clusters may already ship a controllerâ€”point at **`kubectl get pods -n ingress-nginx`** (or vendor namespace) live.

**Run:**

```bash
kubectl apply -f yamls/2-5-3-ingress-controllers-notes.yaml
```

**Expected:** ConfigMap `2-5-3-ingress-controllers-notes` in `kube-system` when allowed.

---

## Step 2 â€” Inspect controller footprint

**What happens when you run this:**

Script lists controller-related workloads and Ingressâ€”output varies by installation.

**Run:**

```bash
bash scripts/inspect-2-5-3-ingress-controllers.sh
```

**Expected:** ConfigMap confirmed; Ingress controller pods **visible** if an addon or chart is installed.

## Video close â€” fast validation

```bash
bash scripts/inspect-2-5-3-ingress-controllers.sh
```

## Troubleshooting

- **No controller pods** â†’ install one; verify **IngressClass** exists (`kubectl get ingressclass`)
- **LoadBalancer `<pending>`** â†’ cloud integration or MetalLB not configured
- **Webhook timeout** â†’ controller admission service unreachable; check **Service** and **endpoints**
- **Wrong controller picks up Ingress** â†’ fix **ingressClassName** and default class annotations
- **Certificate not issued** â†’ separate **cert-manager** / TLS story; check **Challenge** CRs
- **`Forbidden` notes apply** â†’ read YAML offline

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-2-5-3-ingress-controllers.sh` | Controller + Ingress inventory |
| `yamls/2-5-3-ingress-controllers-notes.yaml` | Notes ConfigMap |
| `yamls/failure-troubleshooting.yaml` | Missing controller, webhook, external IP issues |

## Cleanup

```bash
kubectl delete configmap 2-5-3-ingress-controllers-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.5.4 Gateway API](04-gateway-api/README.md)
