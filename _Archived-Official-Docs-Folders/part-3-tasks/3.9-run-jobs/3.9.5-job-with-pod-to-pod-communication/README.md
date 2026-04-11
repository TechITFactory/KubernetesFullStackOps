# 3.9.5 Job with Pod-to-Pod Communication

- Summary: Build a job workflow where worker pods communicate with peer services.
- Content:
  - Batch jobs often depend on in-cluster service endpoints.
  - Validate DNS/service reachability before job execution.
  - Inspect job pod logs for communication failures.
- Lab:

```bash
kubectl create deployment comm-backend --image=nginx:1.27
kubectl expose deployment comm-backend --name=comm-backend --port=80
```

Run communication job:

```bash
cat <<'EOF' > comm-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: comm-job
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: worker
          image: busybox:1.36
          command: ["sh","-c","wget -qO- http://comm-backend && echo ok"]
EOF
kubectl apply -f comm-job.yaml
kubectl logs -l job-name=comm-job
```

Success signal: job logs show backend response and `ok`.
Failure signal: DNS/connectivity errors from job pod.
