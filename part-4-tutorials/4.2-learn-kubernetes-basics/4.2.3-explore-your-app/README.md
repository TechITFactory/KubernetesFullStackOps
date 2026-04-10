# 4.2.3 Explore Your App

- Summary: Inspect deployment, pods, logs, and metadata to understand app state.
- Content:
  - `get`, `describe`, and `logs` are your primary debug loop.
  - Labels/selectors connect deployments, pods, and services.
  - Events explain most scheduling/startup failures.
- Lab:

## Lab Steps (Linux)

```bash
kubectl get deployment kubernetes-bootcamp -o wide
kubectl get pods -l app=kubernetes-bootcamp
kubectl describe pod -l app=kubernetes-bootcamp
kubectl logs -l app=kubernetes-bootcamp --tail=50
kubectl get events --sort-by=.lastTimestamp | tail -n 20
```

Success signal: pod is healthy and logs show normal startup.
Failure signal: warning events repeat with the same error.

EKS extension: same commands are used for day-2 production debugging.

## Transcript

[0:00-0:30] You will inspect runtime state like an on-call engineer.  
[0:30-2:00] `get` gives status, `describe` gives reasons, `logs` give app evidence.  
[2:00-7:00] Run each command and correlate labels, status, and recent events.  
[7:00-9:00] If status is unclear, trust events and logs over assumptions.  
[9:00-10:00] Fast exploration cuts incident resolution time.
