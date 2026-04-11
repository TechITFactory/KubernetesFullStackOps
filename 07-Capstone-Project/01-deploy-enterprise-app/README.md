# 01 Deploy Enterprise Application

## Metadata
- Duration: `30 minutes`
- Difficulty: `Capstone`
- Practical/Theory: `100/0`
- Tested on Kubernetes: `v1.30`

## Capstone Scenario Introduction
Welcome to the Capstone Project. You are the newly hired Lead SRE for *CloudSphere Inc*. The company is launching a highly anticipated multi-tier application. Your mission: Architect, secure, scale, and defend this application using every skill you have learned across Tracks 1 through 6. 

## Learning Objective
- Instantiate a multi-tier architectural foundation (Frontend + Backend Database) natively.

## Lab: Step-by-Step Practical

### Step 1 - Open directory
**Run:**
```bash
cd "$COURSE_DIR/07-Capstone-Project/01-deploy-enterprise-app"
```

### Step 2 - Create the Isolation Boundary

**What happens when you run this:**
You mandate a strict operational namespace for the entire Capstone lifespan.

**Run:**
```bash
kubectl create namespace capstone-prod
```

### Step 3 - Deploy the Architecture

**What happens when you run this:**
We drop the Redis master persistent cache and wire the stateless Frontend deployment directly to it via internal DNS (`redis-master`).

**Run:**
```bash
kubectl apply -f yamls/redis-backend.yaml -n capstone-prod
kubectl apply -f yamls/python-frontend.yaml -n capstone-prod
```

### Step 4 - Verify the Boot Sequence

**Run:**
```bash
kubectl get all -n capstone-prod
```

## Expected Output
A fully operational cluster mapping 1 Redis Pod to 2 active Nginx Frontend Pods, securely walled inside `capstone-prod`.

## Next Mission
[Phase 02: CI/CD and GitOps Integration](../02-cicd-gitops-flow/README.md)
