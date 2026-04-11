# 04 Observability and Scaling

## Metadata
- Duration: `15 minutes`
- Difficulty: `Capstone`

## Learning Objective
- Harden frontend limits and introduce dynamic cloud elasticity out to 8 replicas.

## The Mission
The CEO just announced a flash sale on Twitter. You must prepare the Frontend stateless application to autonomously handle sudden multi-threading CPU spikes. 

## Lab: Step-by-Step Practical

### Step 1 - Open directory
**Run:**
```bash
cd "$COURSE_DIR/07-Capstone-Project/04-observability-verification"
```

### Step 2 - Enable Autonomous Intelligence

**What happens when you run this:**
You deploy a `HorizontalPodAutoscaler` directly targeting the `capstone-frontend` deployment. It allows bursting up to exactly 8 Pods provided CPU saturation exceeds 70%. 

**Run:**
```bash
cat yamls/capstone-hpa.yaml
kubectl apply -f yamls/capstone-hpa.yaml
```

### Step 3 - Verify the Math Engine

**Run:**
```bash
kubectl get hpa -n capstone-prod -w
```

## Next Mission
[Phase 05: The Final Defense](../05-final-defense/README.md)
