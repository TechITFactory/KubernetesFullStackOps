# 3.3.18 Configure Liveness, Readiness and Startup Probes

- Summary: Add health probes to prevent bad pods from receiving traffic.
- Content:
  - Readiness controls traffic eligibility.
  - Liveness restarts unhealthy containers.
  - Startup probe protects slow-starting apps from early restarts.
- Lab:

```bash
cat <<'EOF' > probe-demo.yaml
apiVersion: v1
kind: Pod
metadata:
  name: probe-demo
spec:
  containers:
    - name: app
      image: nginx:1.27
      ports:
        - containerPort: 80
      readinessProbe:
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 5
      livenessProbe:
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 15
      startupProbe:
        httpGet:
          path: /
          port: 80
        failureThreshold: 30
        periodSeconds: 5
EOF
kubectl apply -f probe-demo.yaml
kubectl describe pod probe-demo | grep -A4 -i probe
```

Success signal: probes configured and pod becomes ready.
Failure signal: repeated restarts or probe failures in events.

EKS extension: probe tuning is critical with autoscaling and rolling updates.
