# 3.14.1 Adding Entries to Pod /etc/hosts with HostAliases

- Summary: Add static hostname mappings inside pod `/etc/hosts` via hostAliases.
- Content:
  - `hostAliases` is useful for temporary/manual name mappings.
  - Prefer DNS for long-term service discovery.
  - Validate entries inside container.
- Lab:

```bash
cat <<'EOF' > hostaliases-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostaliases-pod
spec:
  hostAliases:
    - ip: "10.10.10.10"
      hostnames:
        - "legacy.internal.local"
  containers:
    - name: app
      image: busybox:1.36
      command: ["/bin/sh","-c","cat /etc/hosts; sleep 3600"]
EOF
kubectl apply -f hostaliases-pod.yaml
kubectl logs hostaliases-pod
```

Success signal: custom host entry appears in `/etc/hosts`.
Failure signal: host alias missing due to malformed manifest.

EKS extension: use internal DNS records instead of hostAliases for scalable production use.
