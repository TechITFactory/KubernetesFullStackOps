# 3.3.8 Configure RunAsUserName for Windows Pods and Containers

- Summary: Configure Windows container identity using `runAsUserName`.
- Content:
  - Windows workloads use `runAsUserName` for process identity.
  - Identity must exist and be allowed by image/runtime.
  - Validate security context in pod spec and runtime status.
- Lab:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: windows-runas
spec:
  nodeSelector:
    kubernetes.io/os: windows
  containers:
    - name: app
      image: mcr.microsoft.com/windows/nanoserver:ltsc2022
      command: ["cmd","/c","ping -t 127.0.0.1"]
      securityContext:
        windowsOptions:
          runAsUserName: "ContainerUser"
```

Apply and verify:

```bash
kubectl apply -f windows-runas.yaml
kubectl get pod windows-runas -o wide
kubectl get pod windows-runas -o yaml | grep -A8 runAsUserName
```

Success signal: pod starts on Windows node with expected user setting.
Failure signal: pod rejected due to unsupported/missing Windows context.
