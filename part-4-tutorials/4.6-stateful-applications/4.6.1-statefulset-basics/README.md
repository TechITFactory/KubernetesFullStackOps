# 4.6.1 StatefulSet Basics

- Summary: Deploy a StatefulSet and observe stable pod names plus persistent storage.
- Content:
  - StatefulSets provide stable network identity and ordered rollout.
  - Each replica gets its own PVC.
  - Verify identity and data persistence before scaling.
- Lab:

```bash
kubectl create ns stateful-lab
kubectl apply -n stateful-lab -f https://k8s.io/examples/application/mysql/mysql-pv.yaml
kubectl apply -n stateful-lab -f https://k8s.io/examples/application/mysql/mysql-deployment.yaml
kubectl get statefulset,pod,pvc -n stateful-lab
```

Success signal: pods like `mysql-0` are running and PVC is bound.
Failure signal: pods pending due to unbound PVC.

EKS extension: use EBS-backed storage class and verify dynamic provisioning.

## Transcript

[0:00-0:30] You will deploy your first StatefulSet and verify storage identity.  
[0:30-2:00] StatefulSet is used when pod identity and storage must be stable.  
[2:00-7:00] Create namespace, deploy manifests, inspect pods and PVC binding.  
[7:00-9:00] Pending pods usually mean storage class/PVC issues.  
[9:00-10:00] Stable identity + persistent volume is core for databases.
