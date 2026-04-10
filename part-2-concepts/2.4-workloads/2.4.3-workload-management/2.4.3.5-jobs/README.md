# 2.4.3.5 Jobs

- Summary: Jobs manage run-to-completion workloads and differ fundamentally from always-on services.
- Content: Cover completions, backoff, retries, and pod completion semantics.
- Lab: Run the Job example and inspect status fields.

## Assets

- `yamls/job-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/job-demo.yaml
kubectl wait --for=condition=complete job/job-demo --timeout=120s
kubectl logs job/job-demo
```

## Expected output

- Job completes successfully and logs show the expected output line.

## Video close - fast validation

```bash
kubectl get job job-demo
kubectl describe job job-demo | sed -n '/Conditions:/,/Events:/p'
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common backoffLimit, restartPolicy, and parallel job failures.
