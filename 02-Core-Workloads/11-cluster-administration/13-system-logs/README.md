# System logs — teaching transcript

## Intro

**System** **logs** **for** **Kubernetes** **include** **control-plane** **component** **logs** **(apiserver**, **scheduler**, **etcd)**, **kubelet** **journal** **output** **on** **nodes**, **and** **container** **runtime** **logs**. **Access** **patterns** **vary**: **`kubectl logs`** **for** **Pods**, **SSH** **or** **serial** **console** **for** **nodes**, **cloud** **logging** **for** **managed** **control** **planes**. **This** **lesson** **emphasizes** **where** **each** **log** **class** **lives** **and** **RBAC** **to** **`pods/log`**.

**Prerequisites:** [2.11.12 Metrics for Kubernetes object states](../12-metrics-for-kubernetes-object-states/README.md).

## Flow of this lesson

```
  Component emits logs to file or journal
              │
              ▼
  Operator collects (kubectl, SSH, cloud sink)
              │
              ▼
  Correlation with audit and metrics during incidents
```

**Say:**

**On** **GKE**/**EKS**, **I** **tell** **students** **exactly** **which** **console** **menu** **replaces** **`kubectl logs -n kube-system kube-apiserver`** **because** **that** **pod** **may** **not** **exist** **in** **their** **account**.

## Learning objective

- Use **repo** **inspect** **script** **to** **list** **kube-system** **Pods** **as** **log** **targets**.
- Separate **workload** **logs** **from** **node** **system** **logs** **operationally**.

## Why this matters

**Chasing** **apiserver** **errors** **in** **application** **Loki** **when** **they** **only** **exist** **in** **cloud** **audit** **wastes** **critical** **minutes**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/11-cluster-administration/13-system-logs" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-11-13-system-logs-notes.yaml
kubectl get cm -n kube-system 2-11-13-system-logs-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-11-13-system-logs-notes`** when allowed.

---

## Step 2 — kube-system pods as log sources (read-only)

**What happens when you run this:**

**Script** **mirrors** **logging** **lesson** **pattern**—**lists** **likely** **log** **sources**.

**Run:**

```bash
bash scripts/inspect-2-11-13-system-logs.sh 2>/dev/null | head -n 25 || true
```

**Expected:** **kube-system** **pod** **list**.

## Video close — fast validation

```bash
P="$(kubectl get pods -n kube-system -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)"
if [ -n "$P" ]; then kubectl logs -n kube-system "$P" --tail=3 2>/dev/null | head -c 400; echo; fi || true
```

## Troubleshooting

- **`logs` forbidden** → **RBAC** **role** **needs** **`pods/log`**
- **Empty** **logs** **for** **control** **plane** → **logs** **not** **in** **cluster** **API**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-11-13-system-logs-notes.yaml` | Notes ConfigMap |
| `scripts/inspect-2-11-13-system-logs.sh` | **`kubectl get pods -n kube-system`** |

## Cleanup

```bash
kubectl delete configmap 2-11-13-system-logs-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.11.14 Traces for Kubernetes system components](../14-traces-for-kubernetes-system-components/README.md)
