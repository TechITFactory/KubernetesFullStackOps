# 4.4.3 Restrict a Container's Access to Resources with AppArmor

- Summary: Apply an AppArmor profile to restrict container behavior at runtime.
- Content:
  - AppArmor limits what a process can do on the host.
  - Use profile annotations to attach policy to specific containers.
  - Validate both enforcement and failure behavior.
- Lab:

## Lab Steps (Linux)

Check AppArmor availability:

```bash
sudo aa-status
kubectl get nodes -o wide
```

Apply a pod with AppArmor runtime default:

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: apparmor-demo
  annotations:
    container.apparmor.security.beta.kubernetes.io/main: runtime/default
spec:
  containers:
    - name: main
      image: nginx:1.27
EOF
kubectl get pod apparmor-demo
kubectl describe pod apparmor-demo
```

Success signal: pod runs and no AppArmor denial error in events.
Failure signal: pod rejected due to missing/invalid AppArmor profile support.

Cleanup:

```bash
kubectl delete pod apparmor-demo
```

EKS extension: AppArmor support depends on worker node OS/runtime; validate on managed node groups before enforcing broadly.

## Transcript

[0:00-0:30] You will apply AppArmor restrictions to a running container.  
[0:30-2:00] AppArmor is a Linux kernel control to limit process capabilities.  
[2:00-7:00] Check `aa-status`, deploy pod with AppArmor annotation, verify pod and events.  
[7:00-9:00] If it fails, confirm node support and profile availability first.  
[9:00-10:00] Use this pattern for high-risk namespaces before production rollout.
