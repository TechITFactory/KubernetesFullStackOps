# 05 The Final Defense

## Metadata
- Duration: `20 minutes`
- Difficulty: `Capstone Boss Fight`

## Learning Objective
- Rapidly diagnose a live production outage and salvage the architecture under high duress.

## The Mission
A junior engineer ran a rogue script on production! The application API is completely unreachable. 
You must isolate the outage, observe the broken logs, and execute a fix scenario. 

## Lab: Step-by-Step Practical

### Step 1 - Open directory
**Run:**
```bash
cd "$COURSE_DIR/07-Capstone-Project/05-final-defense"
```

### Step 2 - Watch Production Burn

**What happens when you run this:**
This script simulates an unrecoverable structural damage to the networking tier.

**Run:**
```bash
./scripts/chaos-monkey.sh
```

### Step 3 - Triage the Damage

**What happens when you run this:**
You scan the namespaces to identify exactly what was deleted.

**Run:**
```bash
kubectl get all -n capstone-prod
```
*Wait... the pods are up, but `service/redis-master` is structurally missing! Zero data can flow!*

### Step 4 - The Final Fix

**What happens when you run this:**
As the SRE, you execute an immediate cluster patch, referencing the original YAML baseline artifact from Phase 1 to reconstitute the database network bridge.

**Run:**
```bash
kubectl apply -f ../01-deploy-enterprise-app/yamls/redis-backend.yaml -n capstone-prod
```

### Step 5 - Validate Perfection

**Run:**
```bash
kubectl get endpoints -n capstone-prod
```
*The endpoint is mapped. The traffic is flowing. You saved the company.*

## Conclusion
Congratulations. You started this course pulling a basic Minikube image, and you ended it by designing, securing, observing, auto-scaling, and aggressively repairing a multi-tier microservice architecture in a fully isolated namespace.

**You are undeniably ready for production operations.**
