# 03 Autoscaling Decisions

## Metadata
- Duration: `20 minutes`
- Difficulty: `Intermediate`
- Practical/Theory: `80/20`
- Tested on Kubernetes: `v1.30`

## Learning Objective
By the end of this lesson, you will be able to:
- Bind a HorizontalPodAutoscaler (HPA) to a live Deployment.
- Observe Kubernetes scaling mathematics reacting proactively to CPU spikes.

## Why This Matters in Real Jobs
You cannot manually type `kubectl scale deployment web --replicas=10` every time a marketing email goes out and traffic surges. The HPA utilizes the Metrics Server to constantly analyze CPU/Memory loads, spinning up pods instantly dynamically when limits are breached, and shutting them down to save cloud money when traffic sleeps.

## Lab: Step-by-Step Practical

### Step 1 - Open directory
**Run:**
```bash
cd "$COURSE_DIR/06-Observability-and-Reliability/03-autoscaling-decisions"
```

### Step 2 - Launch the Baseline

**What happens when you run this:**
You launch a deployment explicitly programmed to burn CPU cycles. 

**Run:**
```bash
kubectl apply -f yamls/stress-deployment.yaml
```

### Step 3 - Apply the HPA Rules

**What happens when you run this:**
You inform Kubernetes: "If this deployment crosses 50% average CPU utilization, spawn more pods until you hit the maximum ceiling of 10."

**Run:**
```bash
cat yamls/cpu-hpa.yaml
kubectl apply -f yamls/cpu-hpa.yaml
```

### Step 4 - Verify the Auto-Reaction

**What happens when you run this:**
Watch the HPA dashboard live. Within a minute, you should see the `TARGETS` column show the CPU burning past 50%, immediately followed by the `REPLICAS` jumping from 1 to 2, 4, 8, etc.

**Run:**
```bash
kubectl get hpa -w
```

## Troubleshooting (Top 5)
1. **`<unknown>/50%`** -> This means your cluster has no Metrics Server installed. The HPA is conceptually flying blind and cannot execute mathematics. Install the `metrics-server` component immediately.

## Video close — fast validation
**Run:**
```bash
kubectl delete -f yamls/stress-deployment.yaml
kubectl delete -f yamls/cpu-hpa.yaml
```

## Next Lesson
[04 Backup and DR](../04-backup-and-dr/README.md)
