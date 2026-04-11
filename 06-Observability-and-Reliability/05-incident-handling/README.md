# 05 Incident Handling

## Metadata
- Duration: `20 minutes`
- Difficulty: `Intermediate`
- Practical/Theory: `80/20`
- Tested on Kubernetes: `v1.30`

## Learning Objective
By the end of this lesson, you will be able to:
- Extract hidden failure states utilizing `kubectl describe` events.
- Formulate a structural troubleshooting path when hitting `ImagePullBackOff`.

## Why This Matters in Real Jobs
You will spend 70% of your career troubleshooting why someone else's code didn't deploy. The absolute fastest way to resolve an incident is pulling the raw cluster physical events. The `describe` function is the SRE's greatest weapon for reading exact kubelet operational errors.

## Lab: Step-by-Step Practical

### Step 1 - Open directory
**Run:**
```bash
cd "$COURSE_DIR/06-Observability-and-Reliability/05-incident-handling"
```

### Step 2 - Launch the Broken Application

**What happens when you run this:**
We intentionally launch a Pod aggressively configured to ask DockerHub for an image tag that structurally does not exist.

**Run:**
```bash
kubectl apply -f yamls/broken-image-pod.yaml
kubectl get pods
```

### Step 3 - Extract the Post-Mortem

**What happens when you run this:**
You isolate the incident string natively. Skip the YAML footprint at the top of the command output, and scroll entirely to the bottom "Events" table.

**Say:**
The Events tell the exact micro-second truth: "Failed to pull image... repository does not exist or may require 'docker login'". The incident is instantly solved!

**Run:**
```bash
kubectl describe pod crashing-pod
```

## Video close — fast validation
**Run:**
```bash
kubectl delete pod crashing-pod --ignore-not-found
```

## Next Lesson
[Track 07: Capstone Project](../../07-Capstone-Project/README.md)
