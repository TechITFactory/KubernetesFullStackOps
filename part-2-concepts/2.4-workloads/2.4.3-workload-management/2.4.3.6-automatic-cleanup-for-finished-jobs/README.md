# 2.4.3.6 Automatic Cleanup for Finished Jobs

- Summary: Finished jobs can be cleaned up automatically with TTL-based policy instead of accumulating indefinitely.
- Content: Teach cleanup as an operational hygiene feature.
- Lab: Apply the TTL-after-finished example and inspect cleanup behavior.

## Assets

- `yamls/job-ttl-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f yamls/job-ttl-demo.yaml
kubectl wait --for=condition=complete job/job-ttl-demo --timeout=120s
kubectl get job job-ttl-demo -o jsonpath='{.spec.ttlSecondsAfterFinished}{"\n"}'
```

## Expected output

- Job completes; TTL field is present and the controller eventually removes finished Job objects (timing varies).

## Video close - fast validation

```bash
kubectl get job job-ttl-demo
kubectl get events --field-selector involvedObject.name=job-ttl-demo --sort-by=.lastTimestamp | tail -n 15
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common TTL controller delays and finished Job retention issues.
