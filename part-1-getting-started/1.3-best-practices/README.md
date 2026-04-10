# 1.3 Best Practices

- Objective: Learn production-aligned habits early so labs map to real jobs.
- Outcomes:
  - Use repeatable cluster setup and validation checks.
  - Apply secure defaults for workloads and access.
  - Build a verify-before-change workflow.
- Notes:
  - Keep theory short. Focus on commands, checks, and failure recovery.
  - Use Linux shell commands for all practicals.
  - Apply practices locally first, then reuse on EKS.

## Children

- 1.3.1 Considerations for Large Clusters
- 1.3.2 Running in Multiple Zones
- 1.3.3 Validate Node Setup
- 1.3.4 Enforcing Pod Security Standards
- 1.3.5 PKI Certificates and Requirements

## Module wrap — quick validation

When you finish **1.3.5**, run the checklist below once on your lab cluster (same commands work after any single lesson if you changed the cluster).

## Practical Checklist

Run this after each cluster change:

```bash
kubectl get nodes -o wide
kubectl get pods -A
kubectl get events -A --sort-by=.lastTimestamp | tail -n 30
```

Expected:

- All nodes `Ready`
- System pods stable
- No repeated warning events
