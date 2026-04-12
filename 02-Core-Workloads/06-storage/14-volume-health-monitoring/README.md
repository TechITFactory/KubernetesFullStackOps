# Volume Health Monitoring — teaching transcript

## Intro

**Volume health** signals let the **CSI** stack report **abnormal** conditions—latency spikes, path errors, array degradation—upward to Kubernetes so workloads and operators can react (events, **Pod** **status** updates, or future condition fields depending on version and driver). Implementation is **driver-specific** and often behind **feature gates**. This lesson frames **why** health monitoring matters: **PVC Bound** does not mean “IO is fine forever.” **`VolumeAttributesClass`** and metrics from the driver complement API-level health.

**Prerequisites:** [2.6.13 Local Ephemeral Storage](../13-local-ephemeral-storage/README.md).

## Flow of this lesson

```
  CSI driver detects backend fault
              │
              ▼
  Publishes health / metrics (sidecar + API extensions)
              │
              ▼
  Cluster surfaces signals to users (version/driver dependent)
```

**Say:**

Until your driver exposes it, teach **SLOs** on **IO latency** via **metrics**—not only API conditions.

## Learning objective

- Explain the purpose of **volume health monitoring** beyond **PVC Phase=Bound**.
- State dependency on **CSI** driver and **Kubernetes** version.

## Why this matters

Silent **degraded** arrays cause **corruption** before **PVC** phase changes—health bridges that gap when supported.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/06-storage/14-volume-health-monitoring" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Volume health teaching notes.

**Run:**

```bash
kubectl apply -f yamls/2-6-14-volume-health-monitoring-notes.yaml
kubectl get cm -n kube-system 2-6-14-volume-health-monitoring-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-6-14-volume-health-monitoring-notes` when RBAC allows.

---

## Step 2 — Inspect CSI driver pods (read-only)

**What happens when you run this:**

Health sidecars often live next to **node** plugins in **kube-system** or a **csi** namespace.

**Run:**

```bash
kubectl get pods -A 2>/dev/null | grep -i csi | head -n 20 || true
```

**Expected:** CSI-related pod names (varies by platform).

## Video close — fast validation

```bash
kubectl get pvc -A -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name,PHASE:.status.phase' 2>/dev/null | head -n 15 || true
```

## Troubleshooting

- **No health API visible** → normal—rely on **metrics** and **cloud alarms**
- **False healthy** → app-level **fsck** / database checks still required
- **Driver upgrade** → health behavior changes—read release notes
- **Events only** → some drivers surface health only as **Events**
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-6-14-volume-health-monitoring-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-6-14-volume-health-monitoring-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.6.15 Windows Storage](../15-windows-storage/README.md)
