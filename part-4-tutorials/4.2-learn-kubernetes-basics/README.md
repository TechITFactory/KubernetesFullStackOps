# 4.2 Learn Kubernetes Basics

- Objective: Build core Kubernetes muscle memory through command-first labs.
- Outcomes:
  - Create a cluster, deploy, explore, expose, scale, and update an app.
  - Read pod/service/deployment state confidently.
  - Troubleshoot common beginner failures quickly.
- Notes:
  - No fluff theory. Each lesson maps directly to operational actions.
  - Linux commands only.
  - Local-first practice with EKS extension note in each lesson.

## Children

- 4.2.1 Create a Cluster
- 4.2.2 Deploy an App
- 4.2.3 Explore Your App
- 4.2.4 Expose Your App Publicly
- 4.2.5 Scale Your App
- 4.2.6 Update Your App

## Module Completion Check

```bash
kubectl get nodes
kubectl get deploy,pod,svc -A
kubectl rollout history deployment/kubernetes-bootcamp
```
