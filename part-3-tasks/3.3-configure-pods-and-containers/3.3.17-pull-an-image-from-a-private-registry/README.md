# 3.3.17 Pull an Image from a Private Registry

- Summary: Configure image pull secrets and run workloads from private registries.
- Content:
  - Private images require registry credentials in Kubernetes secrets.
  - Use `imagePullSecrets` at pod or service account level.
  - Validate by pulling image with no auth errors.
- Lab:

```bash
kubectl create secret docker-registry regcred \
  --docker-server=<registry-server> \
  --docker-username=<username> \
  --docker-password=<password> \
  --docker-email=<email>
```

Use secret in pod:

```bash
cat <<'EOF' > private-image-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: private-image-pod
spec:
  containers:
    - name: app
      image: <registry-server>/<repo>/<image>:<tag>
  imagePullSecrets:
    - name: regcred
EOF
kubectl apply -f private-image-pod.yaml
kubectl describe pod private-image-pod | grep -i -E "pull|image"
```

Success signal: image pulled and pod starts.
Failure signal: `ImagePullBackOff` or auth denied.

EKS extension: prefer IAM-based auth flows for ECR when possible.
