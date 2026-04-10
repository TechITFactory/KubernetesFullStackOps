# 2.4.3.7 CronJob

- Summary: CronJobs schedule recurring Jobs and should be taught with concurrency and missed-run behavior in mind.
- Content: Cover schedule syntax and execution guarantees.
- Lab: Apply the CronJob demo and inspect job creation over time.

## Assets

- `yamls/cronjob-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/cronjob-demo.yaml
kubectl get cronjob cronjob-demo
kubectl describe cronjob cronjob-demo | sed -n '1,40p'
```

## Expected output

- CronJob is created with a valid schedule and suspend state as defined in the manifest.

## Video close - fast validation

```bash
kubectl get cronjob
kubectl get jobs --sort-by=.metadata.creationTimestamp | tail -n 5
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common schedule syntax, timezone, and concurrency policy failures.
