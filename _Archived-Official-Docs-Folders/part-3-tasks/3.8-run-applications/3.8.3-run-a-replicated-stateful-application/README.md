# 3.8.3 Run a Replicated Stateful Application

- Summary: Run a replicated StatefulSet and validate identity/storage per replica.
- Content:
  - Stateful replicas need stable names and persistent storage.
  - Use headless service and StatefulSet for ordered identity.
  - Validate pod ordinal naming and PVC per replica.
- Lab:

```bash
kubectl create ns stateful-repl
kubectl apply -n stateful-repl -f https://k8s.io/examples/application/cassandra/cassandra-service.yaml
kubectl apply -n stateful-repl -f https://k8s.io/examples/application/cassandra/cassandra-statefulset.yaml
kubectl get statefulset,pod,pvc -n stateful-repl
kubectl rollout status statefulset/cassandra -n stateful-repl
```

Success signal: all replicas ready with expected ordinal pod names.
Failure signal: replicas pending due to storage or scheduling constraints.
