# 2.4.1.5 Disruptions

- Summary: Disruptions are workload interruptions caused by voluntary or involuntary events, and they must be planned for.
- Content: Tie disruptions to PodDisruptionBudgets, draining, and controller expectations.
- Lab: Review the disruption notes and simulate a safe drain strategy.

## Assets

- `yamls/disruption-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/disruption-notes.yaml
kubectl get poddisruptionbudget.policy disruption-demo
kubectl describe poddisruptionbudget disruption-demo
```

## Expected output

- PDB is admitted; status reflects current matching pods (may show `0` until you create pods with `app: disruption-demo`).

## Video close - fast validation

```bash
kubectl get pdb
kubectl get pods -l app=disruption-demo 2>/dev/null || true
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common PDB selector mismatch and eviction/drain failures.
