# 3.9.7 Handling Retriable and Non-retriable Pod Failures with Pod Failure Policy . 28

- Summary: Control Job retry behavior using pod failure policy rules.
- Content:
  - Some failures should retry; others should fail fast.
  - `podFailurePolicy` avoids wasting compute on non-retriable errors.
  - Validate job condition transitions after failures.
- Lab:

```bash
cat <<'EOF' > job-failure-policy.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: policy-job
spec:
  backoffLimit: 6
  podFailurePolicy:
    rules:
      - action: Ignore
        onExitCodes:
          operator: In
          values: [42]
      - action: FailJob
        onExitCodes:
          operator: In
          values: [99]
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: task
          image: busybox:1.36
          command: ["/bin/sh","-c","exit 99"]
EOF
kubectl apply -f job-failure-policy.yaml
kubectl get job policy-job -w
kubectl describe job policy-job
```

Success signal: job fails quickly on configured non-retriable code.
Failure signal: job keeps retrying despite `FailJob` rule.

EKS extension: same job semantics; useful for cost control in batch pipelines.
