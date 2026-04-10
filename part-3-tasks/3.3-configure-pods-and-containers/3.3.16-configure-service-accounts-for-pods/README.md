# 3.3.16 Configure Service Accounts for Pods

- Summary: Attach service accounts to pods for scoped API access.
- Content:
  - Service accounts represent workload identity in cluster.
  - Bind minimum RBAC permissions required by workload.
  - Verify token mount and access behavior.
- Lab:

```bash
kubectl create serviceaccount app-sa
kubectl create role pod-reader --verb=get,list,watch --resource=pods
kubectl create rolebinding app-sa-reader --role=pod-reader --serviceaccount=default:app-sa
```

Run pod with service account:

```bash
cat <<'EOF' > sa-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: sa-pod
spec:
  serviceAccountName: app-sa
  containers:
    - name: app
      image: bitnami/kubectl:latest
      command: ["sh","-c","kubectl get pods; sleep 3600"]
EOF
kubectl apply -f sa-pod.yaml
kubectl logs sa-pod
```

Success signal: pod can list pods via assigned RBAC.
Failure signal: `Forbidden` due to missing binding/permissions.

EKS extension: map service account to IAM role for AWS API access.
