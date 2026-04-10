# 2.4.1.8 Workload Reference

- Summary: Pods are usually not the top-level thing you manage directly in production; higher-level workload resources own them.
- Content: Connect pods to their controllers and ownership chain.
- Lab: Inspect pod owner references from a deployment-created pod.

## Assets

- `yamls/workload-reference-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/workload-reference-notes.yaml
kubectl get configmap workload-reference-notes -n kube-system
```

## Expected output

- Reference notes ConfigMap is present for mapping workload APIs to operations.

## Video close - fast validation

```bash
kubectl api-resources | grep -E 'deployments|statefulsets|daemonsets|jobs|cronjobs' || true
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common workload API discovery and documentation workflow failures.
