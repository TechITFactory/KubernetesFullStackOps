# 2.4.1 Pods

- Summary: Pods are the smallest deployable unit in Kubernetes, but they are far richer than "a single container wrapper".
- Content: This section expands into lifecycle, init/sidecar/ephemeral containers, disruptions, QoS, downward API, user namespaces, and advanced pod configuration.
- Lab: Create pods with different container roles and inspect how Kubernetes treats them.

## Children

- `2.4.1.1 Pod Lifecycle`
- `2.4.1.2 Init Containers`
- `2.4.1.3 Sidecar Containers`
- `2.4.1.4 Ephemeral Containers`
- `2.4.1.5 Disruptions`
- `2.4.1.6 Pod Hostname`
- `2.4.1.7 Pod Quality of Service Classes`
- `2.4.1.8 Workload Reference`
- `2.4.1.9 User Namespaces`
- `2.4.1.10 Downward API`
- `2.4.1.11 Advanced Pod Configuration`

## Module wrap - quick validation

```bash
kubectl get pods -A | head -n 30
kubectl get pdb -A 2>/dev/null || true
kubectl get events -A --sort-by=.lastTimestamp | tail -n 20
```
