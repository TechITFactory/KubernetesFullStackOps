# 4.2.6 Update Your App

- Summary: Perform a rolling update and validate safe rollout/rollback.
- Content:
  - `set image` updates deployment image without full downtime.
  - `rollout status` confirms progress and completion.
  - Keep rollback command ready before any production update.
- Lab:

## Lab Steps (Linux)

```bash
kubectl set image deployment/kubernetes-bootcamp kubernetes-bootcamp=gcr.io/google-samples/kubernetes-bootcamp:v2
kubectl rollout status deployment/kubernetes-bootcamp
kubectl get pods -l app=kubernetes-bootcamp
kubectl rollout history deployment/kubernetes-bootcamp
```

Rollback if needed:

```bash
kubectl rollout undo deployment/kubernetes-bootcamp
```

Success signal: new pods become ready and rollout completes.
Failure signal: rollout stalls and old/new pods remain mixed too long.

EKS extension: same rollout/undo flow applies; add deployment gates in CI/CD.

## Transcript

[0:00-0:30] You will update app version safely and verify rollout.  
[0:30-2:00] Rolling updates reduce risk by replacing pods gradually.  
[2:00-7:00] Set new image, track rollout status, inspect pods and revision history.  
[7:00-9:00] If update fails, execute `rollout undo` immediately.  
[9:00-10:00] Safe update + rollback is a core production skill.
