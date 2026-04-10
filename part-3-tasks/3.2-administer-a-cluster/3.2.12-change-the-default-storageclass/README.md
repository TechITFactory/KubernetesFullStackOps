# 3.2.12 Change the Default StorageClass

- Summary: Switch default StorageClass to control PVC provisioning behavior.
- Content:
  - Default StorageClass is used when PVC omits `storageClassName`.
  - Only one default class should be active.
  - Validate PVC binding after default change.
- Lab:

```bash
kubectl get storageclass
kubectl annotate storageclass <old-default> storageclass.kubernetes.io/is-default-class="false" --overwrite
kubectl annotate storageclass <new-default> storageclass.kubernetes.io/is-default-class="true" --overwrite
kubectl get storageclass
```

Success signal: desired class marked `(default)`.
Failure signal: multiple defaults or no default class.
