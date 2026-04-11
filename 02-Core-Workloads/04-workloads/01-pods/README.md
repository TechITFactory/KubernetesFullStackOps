# 2.4.1 Pods â€” teaching transcript

## Intro

A **Pod** is the smallest deployable unit on Kubernetes: one or more containers that **share a network namespace** (one IP, shared `localhost` policy between containers) and **mount the same volumes** on a single node. Everything higher levelâ€”**Deployments**, **StatefulSets**, **Jobs**, and so onâ€”**creates or replaces Pods**; it does not run containers by magic outside that contract. The **Pod spec** is the **contract between the scheduler and kubelet**: scheduling decisions use the specâ€™s resources, affinity, and tolerations; kubelet uses the same spec to start containers and run probes. When you debug â€œwhy is this not running,â€ you still end at the Pod object even when a controller owns it.

**Prerequisites:** [2.4 module](../README.md); working cluster.

## Flow of this lesson

```
  kubectl / CI applies workload API object
              â”‚
              â–¼
        Controller reconciles
              â”‚
              â–¼
        Pod spec bound to a node
              â”‚
              â–¼
        Containers + volumes on that node
```

**Say:**

The diagram is the same for a hand-written Pod or a Deployment: the Pod is where network and storage namespaces meet; controllers are just automated authors of Pod specs.

## Learning objective

- Describe how Pods **share** network and storage namespaces on one node.
- State that **higher-level workload resources** ultimately manage Pod lifecycle, not a separate runtime primitive.

## Why this matters

Misconfigured **affinity**, **volumes**, or **probes** show up as Pod status; blaming the Deployment without reading the Pod spec wastes time in incidents.

## Children (suggested order)

1. [2.4.1.1 Pod Lifecycle](02-pod-lifecycle/README.md) â€” **start here** (phases, conditions, verify script).
2. [2.4.1.2 Init Containers](03-init-containers/README.md)
3. [2.4.1.3 Sidecar Containers](04-sidecar-containers/README.md)
4. [2.4.1.4 Ephemeral Containers](05-ephemeral-containers/README.md)
5. [2.4.1.5 Disruptions](06-disruptions/README.md)
6. [2.4.1.6 Pod Hostname](07-pod-hostname/README.md)
7. [2.4.1.7 Pod Quality of Service Classes](08-pod-quality-of-service-classes/README.md)
8. [2.4.1.8 Workload Reference](09-workload-reference/README.md)
9. [2.4.1.9 User Namespaces](10-user-namespaces/README.md)
10. [2.4.1.10 Downward API](11-downward-api/README.md)
11. [2.4.1.11 Advanced Pod Configuration](12-advanced-pod-configuration/README.md)

## Module wrap â€” quick validation

**Say:**

This read-only slice catches stuck pods and PDBs before you dive into a single lesson.

```bash
kubectl get pods -A | head -n 30
kubectl get pdb -A 2>/dev/null || true
kubectl get events -A --sort-by=.lastTimestamp | tail -n 20
```

## Troubleshooting

- **No PDBs listed** â†’ normal if you have not applied disruption demos; `|| true` suppresses errors on empty API
- **Many pods `Pending`** â†’ cluster capacity or scheduling constraints; continue with [2.4.1.11](12-advanced-pod-configuration/README.md) topics
- **Events truncated** â†’ raise `tail -n` or filter with `--field-selector`
- **`kubectl get pods -A` slow** â†’ large clusters; add `-l` or `-n` for teaching
- **Permission errors** â†’ use namespace your kubeconfig can read

## Next subsection

[2.4.2 Workload API](../13-workload-api/README.md) or continue into [2.4.3 Workload Management](../15-workload-management/README.md) if you prefer controllers first.
