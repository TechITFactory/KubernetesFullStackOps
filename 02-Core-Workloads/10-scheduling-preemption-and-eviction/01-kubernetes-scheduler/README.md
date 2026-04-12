# Kubernetes Scheduler — teaching transcript

## Intro

The **default** **Kubernetes** **scheduler** **watches** **Pods** **with** **empty** **`spec.nodeName`**, **runs** **filtering** **plugins** **to** **drop** **ineligible** **nodes**, **scores** **the** **remainder**, **picks** **a** **host**, **and** **issues** **a** **bind** **call** **to** **the** **API** **server**. **HA** **clusters** **run** **one** **active** **scheduler** **via** **leader** **election** **(Lease** **object)**. **Custom** **schedulers** **exist** **(alternate** **`spec.schedulerName`)** **but** **most** **clusters** **use** **`default-scheduler`**.

**Prerequisites:** [2.10 module](../README.md); [2.7.4 Resource management for pods and containers](../../07-configuration/04-resource-management-for-pods-and-containers/README.md).

## Flow of this lesson

```
  Pod created (nodeName empty)
              │
              ▼
  Scheduling queue → filter plugins → score plugins → bind
              │
              ▼
  nodeName set; kubelet admits Pod
```

**Say:**

**Filtering** **is** **binary**; **scoring** **breaks** **ties** **between** **nodes** **that** **all** **fit** **the** **Pod’s** **requests**.

## Learning objective

- Describe **filter** **vs** **score** **vs** **bind** **at** **a** **high** **level**.
- Locate **scheduler** **components** **or** **leases** **with** **`kubectl`** **(read-only)**.

## Why this matters

**Every** **“Pending”** **incident** **routes** **through** **this** **pipeline**—**vocabulary** **here** **shortens** **RCA** **time**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/10-scheduling-preemption-and-eviction/01-kubernetes-scheduler" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Lesson **notes** **in** **kube-system**.

**Run:**

```bash
kubectl apply -f yamls/2-10-1-kubernetes-scheduler-notes.yaml
kubectl get cm -n kube-system 2-10-1-kubernetes-scheduler-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap **`2-10-1-kubernetes-scheduler-notes`** when **RBAC** **allows**.

---

## Step 2 — Scheduler pod hint and leader lease (read-only)

**What happens when you run this:**

**Script** **greps** **kube-system** **for** **scheduler** **pods**; **leases** **show** **HA** **leadership**.

**Say:**

On **EKS**/**GKE**/**AKS**, **you** **may** **see** **only** **leases** **and** **metrics**, **not** **a** **Deployment** **named** **kube-scheduler**.

**Run:**

```bash
bash scripts/inspect-2-10-1-kubernetes-scheduler.sh 2>/dev/null || true
kubectl get lease -n kube-system 2>/dev/null | grep -i scheduler | head -n 10 || true
```

**Expected:** **Scheduler** **pod** **lines** **or** **empty**; **lease** **names** **on** **HA** **control** **planes**.

## Video close — fast validation

```bash
kubectl get events -A --field-selector reason=FailedScheduling 2>/dev/null | tail -n 8 || true
```

## Troubleshooting

- **No** **scheduler** **in** **kube-system** → **static** **pod** **name** **varies** **or** **managed** **plane**
- **Pods** **Pending** **without** **events** → **check** **`kubectl get pod -o yaml`** **for** **`schedulerName`**, **gates**, **taints**
- **`Forbidden` notes** → **read** **`yamls/2-10-1-kubernetes-scheduler-notes.yaml`** **from** **git**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-10-1-kubernetes-scheduler-notes.yaml` | Notes ConfigMap |
| `scripts/inspect-2-10-1-kubernetes-scheduler.sh` | Lists **kube-system** **pods** **matching** **scheduler** |

## Cleanup

```bash
kubectl delete configmap 2-10-1-kubernetes-scheduler-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.10.2 Assigning Pods to Nodes](../02-assigning-pods-to-nodes/README.md)
