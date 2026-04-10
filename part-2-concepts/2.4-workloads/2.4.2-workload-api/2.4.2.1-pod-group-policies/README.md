# 2.4.2.1 Pod Group Policies

- Summary: Pod grouping policies influence how related pods are placed, disrupted, or treated as a unit across scheduling and workload patterns.
- Content: Use this topic to connect affinity, topology spread, PDBs, and emerging grouped-scheduling ideas.
- Lab: Review the group policy notes and relate them to your workload topology choices.

## Assets

- `yamls/pod-group-policies-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/pod-group-policies-notes.yaml
kubectl get configmap pod-group-policies-notes -n kube-system
```

## Expected output

- Notes ConfigMap is available for comparing scheduling/grouping policies.

## Video close - fast validation

```bash
kubectl api-resources | grep -i scheduling || true
kubectl get pods -A | head -n 15
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common scheduling policy API gaps and feature-gate mismatches.
