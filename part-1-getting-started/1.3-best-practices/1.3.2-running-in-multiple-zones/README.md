# 1.3.2 Running in Multiple Zones

- Summary: Multi-zone Kubernetes improves resilience only when nodes, workloads, and storage choices are aligned with real failure domains.
- Content: This section includes zone labeling checks, spread constraints, and anti-affinity examples to prevent all replicas from landing in a single zone.
- Lab: Label nodes by zone, deploy the sample workload, and confirm replicas distribute across availability zones.

## Assets

- `scripts/check-multi-zone-labels.sh`
- `yamls/multi-zone-deployment.yaml`
- `yamls/storage-zone-notes.yaml`
- `yamls/failure-troubleshooting.yaml`

## Lab Steps (Linux)

```bash
./scripts/check-multi-zone-labels.sh
kubectl apply -f yamls/multi-zone-deployment.yaml
kubectl get pods -o wide
```

## Expected Output

- Nodes show valid zone labels.
- Replicas distribute across zones.

## Transcript

[0:00–0:30] You will enforce true multi-zone resilience, not just multi-zone node count.  
[0:30–2:00] Zone-aware scheduling prevents single-zone outages from taking all replicas.  
[2:00–7:00] Validate labels, deploy sample, verify distribution in pod/node output.  
[7:00–9:00] Use troubleshooting YAML for skewed placement or storage-zone mismatch.  
[9:00–10:00] Multi-zone is only useful when scheduling and storage are zone-aware.

## Video close — fast validation

```bash
./scripts/check-multi-zone-labels.sh
kubectl get nodes -L topology.kubernetes.io/zone
kubectl get pods -o wide
```
