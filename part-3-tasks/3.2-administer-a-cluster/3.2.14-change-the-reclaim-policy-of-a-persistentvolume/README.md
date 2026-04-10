# 3.2.14 Change the Reclaim Policy of a PersistentVolume

- Summary: Update PV reclaim policy to match data retention requirements.
- Content:
  - `Delete` removes backend volume after PVC release.
  - `Retain` preserves data for manual recovery.
  - Validate policy before deleting claims.
- Lab:

```bash
kubectl get pv
kubectl patch pv <pv-name> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
kubectl get pv <pv-name> -o yaml | grep -i persistentVolumeReclaimPolicy
```

Success signal: reclaim policy updated to intended value.
Failure signal: PVC lifecycle behavior does not match expected retention.
