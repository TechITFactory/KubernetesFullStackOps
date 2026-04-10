# 2.4.2 Workload API

- Summary: The workload API defines the higher-level Kubernetes abstractions that manage pods as durable application intent.
- Content: This section frames workload resources as APIs with selectors, strategies, and lifecycle semantics.
- Lab: Compare workload resources and inspect their API fields.

## Children

- `2.4.2.1 Pod Group Policies`

## Module wrap - quick validation

```bash
kubectl api-resources | grep -E 'deployments|replicasets|statefulsets|daemonsets|jobs|cronjobs' || true
kubectl get cm -n kube-system | grep -E 'pod-group|workload' || true
```
