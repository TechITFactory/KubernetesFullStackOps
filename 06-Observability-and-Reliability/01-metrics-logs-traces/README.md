# 01 Metrics, Logs, and Traces

## Metadata
- Duration: `15 minutes`
- Difficulty: `Beginner`
- Practical/Theory: `60/40`
- Tested on Kubernetes: `v1.30`

## Learning Objective
By the end of this lesson, you will be able to:
- Retrieve real-time terminal logging output from applications.
- Identify how Prometheus logically scrapes application targets using a ServiceMonitor.

## Why This Matters in Real Jobs
When an application crashes in a distributed system, you can't just SSH into a server and read `/var/log`. The Container Runtime ephemeralizes everything. Your first lines of defense are streaming the native logs and reading structured telemetry (metrics).

## Lab: Step-by-Step Practical

### Step 1 - Open directory
**Run:**
```bash
cd "$COURSE_DIR/06-Observability-and-Reliability/01-metrics-logs-traces"
```

### Step 2 - Execute the Mock Logging App

**What happens when you run this:**
You run a shell script that mimics a database transaction trace throwing a failure.

**Run:**
```bash
./scripts/generate-logs.sh
```

### Step 3 - Inspect a ServiceMonitor Spec

**What happens when you run this:**
You read the YAML blueprint telling Prometheus exactly where to scrape metrics. This defines the HTTP path `/metrics` hitting targeting labels `app: frontend` every 15 seconds.

**Run:**
```bash
cat yamls/service-monitor.yaml
```

## Next Lesson
[02 Alerting and SLOs](../02-alerting-and-slos/README.md)
