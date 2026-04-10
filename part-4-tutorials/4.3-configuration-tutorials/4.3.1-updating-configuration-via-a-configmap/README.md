# 4.3.1 Updating Configuration via a ConfigMap

- Summary: Update app configuration without rebuilding container images.
- Content:
  - ConfigMaps separate config from image.
  - Rolling restart applies new config for env-var based settings.
  - Always validate values from inside a running pod.
- Lab:

## Lab Steps (Linux)

```bash
kubectl create configmap app-config --from-literal=APP_MODE=dev --from-literal=APP_COLOR=blue
kubectl create deployment cfg-demo --image=nginx:1.27
kubectl set env deployment/cfg-demo --from=configmap/app-config
kubectl rollout status deployment/cfg-demo
kubectl exec deploy/cfg-demo -- printenv | grep APP_
```

Update config and re-apply:

```bash
kubectl create configmap app-config --from-literal=APP_MODE=prod --from-literal=APP_COLOR=green -o yaml --dry-run=client | kubectl apply -f -
kubectl rollout restart deployment/cfg-demo
kubectl rollout status deployment/cfg-demo
kubectl exec deploy/cfg-demo -- printenv | grep APP_
```

Success signal: env values change to `APP_MODE=prod`, `APP_COLOR=green`.
Failure signal: old values remain after restart.

EKS extension: same pattern is used for environment-specific settings.
