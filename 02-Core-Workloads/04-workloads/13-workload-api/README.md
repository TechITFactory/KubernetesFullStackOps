# 2.4.2 Workload API â€” teaching transcript

## Intro

The **workload API** is the family of Kubernetes resources that express **durable intent** about how Pods should be created and kept healthy. Each typeâ€”**Deployment**, **StatefulSet**, **DaemonSet**, **Job**, **CronJob**â€”wraps a **Pod template** plus **selector** rules and **strategy** fields that define rollout or completion semantics. Controllers compare **observed** Pod labels and counts to **spec** and reconcile continuously. Understanding **selector immutability**, **template updates**, and **revision history** (where applicable) is what separates â€œI applied YAMLâ€ from â€œI know what the controller will do next.â€

**Prerequisites:** [2.4.1 Pods](../01-pods/README.md); [2.4.3 Workload Management](../15-workload-management/README.md) optional preview.

## Flow of this lesson

```
  Workload object (template + selector + strategy)
              â”‚
              â–¼
  Controller creates/updates Pods
              â”‚
              â–¼
  Status (replicas, conditions, collisions)
```

**Say:**

The **template** is a Pod spec embedded in another objectâ€”debugging still ends at **Pod** events.

## Learning objective

- Compare **Deployment**, **StatefulSet**, **DaemonSet**, and **Job** at the API level: **selector**, **template**, **strategy**.
- Use **`kubectl api-resources`** to discover workload-related kinds for your cluster version.

## Why this matters

RBAC, GitOps validators, and policy engines all key off these API shapesâ€”naming the wrong `apiVersion` breaks pipelines.

## Children

- [2.4.2.1 Pod group policies](14-pod-group-policies/README.md) â€” **LimitRange**, **ResourceQuota**, and namespace defaults

## Module wrap â€” quick validation

**Say:**

I grep for the big five workload kinds before recording a lesson so short names match the server.

```bash
kubectl api-resources | grep -E 'deployments|replicasets|statefulsets|daemonsets|jobs|cronjobs' || true
kubectl get cm -n kube-system | grep -E 'pod-group|workload' || true
```

## Troubleshooting

- **Empty grep** â†’ run plain `kubectl api-resources`â€”feature gates or CRD-only clusters differ
- **No ConfigMaps** â†’ notes not applied yet; not an error
- **Deprecated `extensions/v1beta1` in old docs** â†’ always `kubectl explain` your live API
- **Duplicate owners** â†’ overlapping selectors between workloadsâ€”incident pattern
- **Cannot explain resource** â†’ check plural name and API group

## Next

[2.4.3 Workload Management](../15-workload-management/README.md)
