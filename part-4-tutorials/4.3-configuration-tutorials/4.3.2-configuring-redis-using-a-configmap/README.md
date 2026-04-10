# 4.3.2 Configuring Redis Using a ConfigMap

- Summary: Inject custom Redis config using a ConfigMap-mounted file.
- Content:
  - File-based config updates runtime behavior.
  - Volume mounts are better than hardcoding config in images.
  - Validate config by reading mounted files in the pod.
- Lab:

## Lab Steps (Linux)

```bash
cat <<'EOF' > redis.conf
maxmemory 64mb
maxmemory-policy allkeys-lru
appendonly yes
EOF

kubectl create configmap redis-config --from-file=redis.conf=./redis.conf
kubectl run redis-demo --image=redis:7 --restart=Never --overrides='
{
  "apiVersion":"v1",
  "spec":{
    "containers":[
      {
        "name":"redis-demo",
        "image":"redis:7",
        "command":["redis-server","/etc/redis/redis.conf"],
        "volumeMounts":[{"name":"cfg","mountPath":"/etc/redis"}]
      }
    ],
    "volumes":[{"name":"cfg","configMap":{"name":"redis-config"}}]
  }
}'
kubectl get pod redis-demo
kubectl exec redis-demo -- cat /etc/redis/redis.conf
```

Success signal: pod `Running` and mounted config matches expected values.
Failure signal: pod crash due to invalid config syntax.

EKS extension: same ConfigMap mount pattern works unchanged.
