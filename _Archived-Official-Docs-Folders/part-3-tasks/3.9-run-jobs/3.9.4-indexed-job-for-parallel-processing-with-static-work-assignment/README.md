# 3.9.4 Indexed Job for Parallel Processing with Static Work Assignment

- Summary: Run indexed jobs so each pod gets a stable work index.
- Content:
  - Indexed jobs split static workloads deterministically.
  - Each pod sees `JOB_COMPLETION_INDEX`.
  - Validate each index executes once.
- Lab:

```bash
cat <<'EOF' > indexed-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: indexed-job
spec:
  completions: 4
  parallelism: 2
  completionMode: Indexed
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: worker
          image: busybox:1.36
          command: ["sh","-c","echo index=$JOB_COMPLETION_INDEX; sleep 5"]
EOF
kubectl apply -f indexed-job.yaml
kubectl get pods -l job-name=indexed-job
kubectl logs -l job-name=indexed-job
```

Success signal: logs show distinct indexes (0..N-1).
Failure signal: missing/duplicated expected index executions.
