# 02 CI/CD and GitOps Flow

## Metadata
- Duration: `15 minutes`
- Difficulty: `Capstone`

## Learning Objective
- Mutate the live Capstone application to be strictly ruled by Argo CD.

## The Mission
Your developers are complaining that `kubectl apply` takes too long. CTO wants you to switch the delivery pipeline to a strict GitOps model. You need to bind the `capstone-prod` namespace strictly to a Git source of truth.

## Lab: Step-by-Step Practical

### Step 1 - Open directory
**Run:**
```bash
cd "$COURSE_DIR/07-Capstone-Project/02-cicd-gitops-flow"
```

### Step 2 - Apply the Controller Matrix

**What happens when you run this:**
You deploy an Application CRD that instructs Argo CD to hijack control of the `capstone-prod` namespace, locking its configuration state aggressively to the defined Git Repository. 

**Run:**
```bash
cat yamls/capstone-argocd-app.yaml
kubectl apply -f yamls/capstone-argocd-app.yaml
```

## Next Mission
[Phase 03: Security Enforcement](../03-security-enforcement/README.md)
