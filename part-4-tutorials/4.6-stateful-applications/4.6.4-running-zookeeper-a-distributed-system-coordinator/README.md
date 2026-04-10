# 4.6.4 Running ZooKeeper, A Distributed System Coordinator

- Summary: Run ZooKeeper on Kubernetes and validate quorum member readiness.
- Content:
  - ZooKeeper needs ordered startup and stable member identity.
  - StatefulSet + headless service is standard deployment pattern.
  - Validate health and leader election basics.
- Lab:

```bash
kubectl apply -f https://k8s.io/examples/application/zookeeper/zookeeper.yaml
kubectl get statefulset,pod,svc,pvc -l app=zk
kubectl rollout status statefulset/zookeeper
kubectl logs zookeeper-0 | tail -n 30
```

Success signal: all replicas running and StatefulSet rollout complete.
Failure signal: quorum errors in logs and replicas not ready.

EKS extension: apply anti-affinity to avoid colocating quorum nodes.

## Transcript

[0:00-0:30] You will deploy ZooKeeper and verify cluster readiness.  
[0:30-2:00] Coordination systems need stable identity and quorum.  
[2:00-7:00] Apply manifest, inspect resources, track rollout, review logs.  
[7:00-9:00] Quorum failures are usually DNS, networking, or startup-order issues.  
[9:00-10:00] This lab teaches production-safe distributed-system checks.
