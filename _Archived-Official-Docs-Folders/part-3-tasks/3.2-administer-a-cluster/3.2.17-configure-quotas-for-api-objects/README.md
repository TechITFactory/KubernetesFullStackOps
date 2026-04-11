# 3.2.17 Configure Quotas for API Objects

- Summary: Enforce API object quotas to prevent namespace overconsumption.
- Content:
  - Object quotas limit count of pods/services/secrets and more.
  - Protects API server and namespace fairness.
  - Validate denied object creation when quota exceeded.
- Lab:

```bash
kubectl create ns quota-lab
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: object-quota
  namespace: quota-lab
spec:
  hard:
    pods: "5"
    services: "5"
    secrets: "10"
EOF
kubectl describe resourcequota object-quota -n quota-lab
```

Success signal: quota applies and usage counters update.
Failure signal: object creation not blocked after limit reached.
