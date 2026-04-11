# 3.2.30 Limit Storage Consumption

- Summary: Enforce namespace storage limits using ResourceQuota.
- Content:
  - Storage quotas prevent noisy teams from exhausting cluster storage.
  - Quotas should be applied per namespace with clear limits.
  - Validate denial behavior when requests exceed quota.
- Lab:

```bash
kubectl create ns storage-lab
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: storage-quota
  namespace: storage-lab
spec:
  hard:
    requests.storage: 2Gi
EOF
kubectl get resourcequota -n storage-lab
kubectl describe resourcequota storage-quota -n storage-lab
```

Success signal: quota visible and enforced in namespace.
Failure signal: PVC creation exceeding limit is incorrectly allowed.

EKS extension: pair quotas with StorageClass defaults and monitoring alerts.
