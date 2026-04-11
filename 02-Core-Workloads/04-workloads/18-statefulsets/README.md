# 2.4.3.3 StatefulSets â€” teaching transcript

## Intro

A **StatefulSet** gives Pods **stable network identity** and **ordered** lifecycle. Pods are named **`{name}-{ordinal}`** (`â€¦-0`, `â€¦-1`, â€¦). By default, **scale-up** creates **lower ordinals first** and waits for readiness before the next; **scale-down** removes **higher ordinals first**. The **`serviceName`** field links to a **headless Service** (`clusterIP: None`) so DNS can resolve **per-pod** records. **`volumeClaimTemplates`** provisions a **distinct PVC** per ordinalâ€”this demo omits PVCs to stay small. **`updateStrategy.type: RollingUpdate`** on StatefulSet rolls **from highest ordinal to lowest** (reverse of creation order) so ordered apps drain predictablyâ€”confirm exact semantics in docs for your version.

**Prerequisites:** [2.4.3.2 ReplicaSet](../17-replicaset/README.md); [2.4.1.1 Pod Lifecycle](../../01-pods/02-pod-lifecycle/README.md) recommended.

## Learning objective

- Explain **stable network identity** and **ordinal** pod names.
- Contrast **ordered** StatefulSet lifecycle with **parallel** Deployment churn.
- Read StatefulSet status with a **headless Service**.
- Describe **`RollingUpdate`** ordinal order at a high level.

## Why this matters

Databases, Kafka brokers, and similar systems depend on **predictable names** and **per-instance DNS**. StatefulSet is the standard controller for that pattern.

## Flow of this lesson

```
  Headless Service (clusterIP: None)
              â”‚
              â–¼
  StatefulSet â†’ pod-0 â†’ pod-1 â†’ ...
              â”‚
              â–¼
  DNS: pod-N.service.namespace.svc.cluster.local
```

**Say:**

Without **headless Service**, you lose the usual **per-pod DNS** patternâ€”charts always wire both together.

## Concepts (short theory)

- **Parallel pod management** exists for faster startups when ordering is unnecessaryâ€”not used in this demo.
- Add **`volumeClaimTemplates`** when you practice storageâ€”see failure YAML for PVC drills.

---

## Step 1 â€” Apply StatefulSet and Service

**What happens when you run this:**

Headless Service plus StatefulSet with **replicas: 2**; controller creates **`â€¦-0`** then **`â€¦-1`** when using ordered policy.

**Say:**

I time-lapse **`kubectl get pods -w`** for the audience to feel **serial** creation.

**Run:**

```bash
kubectl apply -f yamls/statefulset-demo.yaml
kubectl rollout status statefulset/statefulset-demo --timeout=180s
kubectl get pods -l app=statefulset-demo -o wide
```

**Expected:** Two pods `Running`, names ending in `-0` and `-1`, both `READY`.

---

## Step 2 â€” Verify script

**What happens when you run this:**

Checks rollout, ordinal names, and headless Service presence.

**Run:**

```bash
chmod +x scripts/verify-statefulset-lesson.sh
./scripts/verify-statefulset-lesson.sh
```

**Expected:** Script succeeds.

## Troubleshooting

- **`Waiting for pod â€¦-0 to be ready`** forever â†’ fix **readiness** on first ordinalâ€”blocks the chain
- **PVC `Pending`** â†’ storage class or quota (when using PVC templates)
- **DNS does not resolve** â†’ Service not headless or wrong **`serviceName`**
- **Ordered rollout too slow** â†’ evaluate **partition** and **parallel** policies for your version
- **Pod name collision on rapid re-apply** â†’ wait for full termination before recreate
- **Verify fails** â†’ leftover pods from partial delete

## Video close â€” fast validation

**What happens when you run this:**

Lists StatefulSet, headless Service, and ordinal pods.

**Say:**

I read pod **FQDN** pattern aloud even though `get` only shows short names.

```bash
kubectl get sts,svc statefulset-demo
kubectl get pods -l app=statefulset-demo -o wide
```

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/statefulset-demo.yaml` | Headless Service + 2-replica StatefulSet (nginx) |
| `yamls/failure-troubleshooting.yaml` | PVC/DNS/ordering drills |
| `scripts/verify-statefulset-lesson.sh` | Rollout + ordinal pod names + headless hint |

## Cleanup

```bash
kubectl delete -f yamls/statefulset-demo.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[2.4.3.4 DaemonSet](../19-daemonset/README.md)
