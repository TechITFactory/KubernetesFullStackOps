# Liveness, Readiness, and Startup Probes — teaching transcript

## Intro

**Probes** are checks the **kubelet** runs against a container: **liveness** decides whether to **restart** a stuck process; **readiness** decides whether the Pod receives **Service** traffic (endpoints); **startup** disables **liveness** (and optionally **readiness**) until slow apps finish booting—preventing **restart loops** on Java-style warmups. Each probe can be **exec**, **httpGet**, or **tcpSocket**, with **initialDelaySeconds**, **periodSeconds**, **timeoutSeconds**, **successThreshold**, and **failureThreshold**. Mis-tuned **liveness** causes **flapping**; mis-tuned **readiness** causes **503s** or **empty endpoints**.

**Prerequisites:** [2.7.2 Secrets](../02-secrets/README.md); [Services](../../05-services-load-balancing-and-networking/01-service/README.md) for readiness ↔ endpoints.

## Flow of this lesson

```
  startupProbe (optional)
        │
        ▼
  livenessProbe  ──fail──► kubelet restarts container
  readinessProbe ──fail──► removed from Service endpoints
```

**Say:**

I never point **liveness** at a dependency the app does not control—**DB down** should not **restart** the app blindly.

## Learning objective

- Distinguish **liveness**, **readiness**, and **startup** probe effects.
- Compare **httpGet**, **exec**, and **tcpSocket** probe handlers.
- Tune **failureThreshold** and **periodSeconds** tradeoffs at a conceptual level.

## Why this matters

Half of “Kubernetes keeps killing my pod” tickets are **too aggressive liveness** during **GC** or **CPU** starvation.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/07-configuration/03-liveness-readiness-and-startup-probes" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Probe teaching notes in **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-7-3-liveness-readiness-and-startup-probes-notes.yaml
kubectl get cm -n kube-system 2-7-3-liveness-readiness-and-startup-probes-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-7-3-liveness-readiness-and-startup-probes-notes` when allowed.

---

## Step 2 — Run inspect script

**What happens when you run this:**

Lists **Pods** wide—use to spot **RESTARTS** and probe-driven churn.

**Run:**

```bash
bash scripts/inspect-2-7-3-liveness-readiness-and-startup-probes.sh
```

**Expected:** Pod table; script exits 0.

---

## Step 3 — Explain probe fields (read-only)

**What happens when you run this:**

**`kubectl explain`** for probe schema on containers.

**Run:**

```bash
kubectl explain pod.spec.containers.livenessProbe 2>/dev/null | head -n 30 || true
kubectl explain pod.spec.containers.readinessProbe 2>/dev/null | head -n 20 || true
kubectl explain pod.spec.containers.startupProbe 2>/dev/null | head -n 20 || true
```

**Expected:** Field docs for your API version.

## Video close — fast validation

```bash
kubectl get pods -A -o wide 2>/dev/null | head -n 20 || true
kubectl get events -A --field-selector reason=Unhealthy 2>/dev/null | tail -n 10 || true
```

## Troubleshooting

- **`CrashLoopBackOff` + Unhealthy** → **liveness** too strict or **timeout** too low under load
- **Service has no endpoints** → **readiness** fails—`describe pod` **Conditions**
- **Startup never succeeds** → **httpGet** path wrong or **TLS** mismatch (**scheme: HTTPS**)
- **Exec probe overhead** → shell in minimal image missing—use **binary** health or **httpGet**
- **gRPC apps** → use **grpc** probe type when supported on your version

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/inspect-2-7-3-liveness-readiness-and-startup-probes.sh` | `kubectl get pods -A -o wide` |
| `yamls/2-7-3-liveness-readiness-and-startup-probes-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-7-3-liveness-readiness-and-startup-probes-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.7.4 Resource Management for Pods and Containers](../04-resource-management-for-pods-and-containers/README.md)
