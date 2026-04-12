# Logging architecture — teaching transcript

## Intro

**Kubernetes** **logging** **architecture** **separates** **container** **stdout/stderr** **(handled** **by** **container** **runtime)**, **node-level** **collection**, **cluster-level** **aggregation**, **and** **control-plane** **component** **logs**. **Admins** **choose** **DaemonSets**, **sidecars**, **or** **cloud** **logging** **agents**. **The** **API** **does** **not** **stream** **all** **Pod** **logs** **centrally**—**operators** **integrate** **Loki**, **Elasticsearch**, **OpenSearch**, **or** **vendor** **pipes**.

**Prerequisites:** [2.11.8 Good practices for dynamic resource allocation as a cluster admin](../08-good-practices-for-dynamic-resource-allocation-as-a-cluster-admin/README.md).

## Flow of this lesson

```
  Container writes stdout/stderr
              │
              ▼
  Runtime + node agent ships to sink
              │
              ▼
  Retention, RBAC, and search in log backend
```

**Say:**

**I** **warn** **students** **that** **`kubectl logs`** **is** **great** **for** **one** **Pod** **and** **terrible** **for** **compliance**—**that** **needs** **central** **retention**.

## Learning objective

- Describe **the** **three** **common** **log** **paths** **(workload**, **node**, **control** **plane)**.
- Use **repo** **inspect** **script** **to** **see** **kube-system** **agents** **(indirect)**.

## Why this matters

**Incident** **response** **without** **indexed** **logs** **means** **`kubectl`** **shell** **games** **during** **outages**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/11-cluster-administration/09-logging-architecture" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-11-9-logging-architecture-notes.yaml
kubectl get cm -n kube-system 2-11-9-logging-architecture-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-11-9-logging-architecture-notes`** when allowed.

---

## Step 2 — kube-system pods (read-only)

**What happens when you run this:**

**Script** **lists** **kube-system** **pods** **where** **log** **agents** **often** **live**.

**Run:**

```bash
bash scripts/inspect-2-11-9-logging-architecture.sh 2>/dev/null | head -n 25 || true
kubectl get pods -n kube-system -o name 2>/dev/null | grep -iE 'fluent|vector|log' | head -n 10 || true
```

**Expected:** **kube-system** **pod** **names**; **optional** **logging** **agent** **matches**.

## Video close — fast validation

```bash
kubectl logs -n kube-system -l tier=control-plane --tail=1 2>/dev/null | head -c 200; echo
```

## Troubleshooting

- **Permission** **denied** **on** **logs** → **RBAC** **to** **pods/log** **subresource**
- **Rotated** **logs** **missing** **in** **central** **sink** → **agent** **buffer** **or** **network** **policy**
- **`Forbidden` notes** → **offline** **YAML**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-11-9-logging-architecture-notes.yaml` | Notes ConfigMap |
| `scripts/inspect-2-11-9-logging-architecture.sh` | **`kubectl get pods -n kube-system`** |

## Cleanup

```bash
kubectl delete configmap 2-11-9-logging-architecture-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.11.10 Compatibility version for Kubernetes control plane components](../10-compatibility-version-for-kubernetes-control-plane-components/README.md)
