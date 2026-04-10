# 4.6.3 Example: Deploying Cassandra with a StatefulSet

- Summary: Deploy Cassandra StatefulSet and verify clustered pod identity.
- Content:
  - Cassandra relies on stable identities and peer discovery.
  - Headless services are common for stateful peer communication.
  - Verify each replica startup and readiness.
- Lab:

```bash
kubectl apply -f https://k8s.io/examples/application/cassandra/cassandra-service.yaml
kubectl apply -f https://k8s.io/examples/application/cassandra/cassandra-statefulset.yaml
kubectl rollout status statefulset/cassandra
kubectl get pod -l app=cassandra -o wide
```

Success signal: replicas come up in order and become ready.
Failure signal: later replicas wait forever due to seed/service issues.

EKS extension: spread replicas across zones using topology-aware scheduling.

## Transcript

[0:00-0:30] You will deploy a distributed stateful system on Kubernetes.  
[0:30-2:00] Cassandra needs stable peer identities to form a healthy ring.  
[2:00-7:00] Apply service and StatefulSet, track rollout, inspect pod states.  
[7:00-9:00] Diagnose seed DNS and readiness probes when rollout stalls.  
[9:00-10:00] This pattern applies to many distributed data systems.
