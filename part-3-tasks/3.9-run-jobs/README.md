# 3.9 Run Jobs

- Objective: Build reliable one-off and scheduled batch workloads.
- Outcomes:
  - Run Jobs and CronJobs with proper retry and failure policy controls.
  - Use parallelism strategies for batch throughput.
  - Debug job failures with pod events and logs.
- Notes:
  - Practical-first: submit, monitor, validate, recover.
  - Linux-only command examples.
  - Same patterns apply to local and EKS batch workloads.

## Children

- 3.9.1 Running Automated Tasks with a CronJob
- 3.9.2 Coarse Parallel Processing Using a Work Queue
- 3.9.3 Fine Parallel Processing Using a Work Queue
- 3.9.4 Indexed Job for Parallel Processing with Static Work Assignment
- 3.9.5 Job with Pod-to-Pod Communication
- 3.9.6 Parallel Processing Using Expansions
- 3.9.7 Handling Retriable and Non-retriable Pod Failures with Pod Failure Policy . 28

## Module Baseline Checks

```bash
kubectl get jobs,cronjobs -A
kubectl get pods -A --field-selector=status.phase=Failed
kubectl get events -A --sort-by=.lastTimestamp | tail -n 30
```
