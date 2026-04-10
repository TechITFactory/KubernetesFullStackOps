# 3.4.4 Troubleshooting Clusters

- Summary: Use a fast cluster triage workflow to find and fix common failures.
- Content:
  - Check nodes, system pods, events, then failing workload details.
  - Trust evidence from events and logs over assumptions.
  - Verify recovery after each fix.
- Lab:

```bash
kubectl get nodes -o wide
kubectl get pods -n kube-system
kubectl get events -A --sort-by=.lastTimestamp | tail -n 50
kubectl top nodes
kubectl top pods -A
```

Deep dive a failing pod:

```bash
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous
```

Success signal: root cause identified and workload returns healthy.
Failure signal: repeated warning events continue after change.

EKS extension: include `kubectl get nodes -L eks.amazonaws.com/nodegroup`.
