# 1.3.1 Considerations for Large Clusters

- Summary: Large clusters demand deliberate design around scalability, failure domains, API efficiency, and workload distribution.
- Content: This section focuses on node/pod sizing guardrails, topology spread, API budget awareness, and operational readiness checks before cluster growth.
- Lab: Review the planning checklist, apply the topology spread example, and validate a scale-readiness baseline.

## Assets

- `scripts/check-large-cluster-readiness.sh`
- `yamls/large-cluster-planning-checklist.yaml`
- `yamls/topology-spread-sample.yaml`
- `yamls/failure-troubleshooting.yaml`

**Teaching tip:** **What happens when you run this** is below; script header in `scripts/check-large-cluster-readiness.sh` matches.

## Lab Steps (Linux)

**What happens when you run this:**  
- `check-large-cluster-readiness.sh` — counts nodes/pods, probes PriorityClass/PDB/`/readyz`, prints topology labels — read-only warnings.  
- `kubectl apply topology-spread-sample.yaml` — creates/updates sample workload with spread constraints (cluster change).  
- `kubectl get pods -o wide` — shows which node each pod landed on (read-only).

```bash
./scripts/check-large-cluster-readiness.sh
kubectl apply -f yamls/topology-spread-sample.yaml
kubectl get pods -o wide
```

## Expected Output

- Readiness script reports pass/warn per cluster sizing criteria.
- Sample workload pods distribute across nodes.

## Transcript

[0:00–0:30] You will validate if your cluster is ready to scale safely.  
[0:30–2:00] Large clusters fail when planning is skipped, not when traffic starts.  
[2:00–7:00] Run readiness script, apply spread sample, verify pod placement.  
[7:00–9:00] Use troubleshooting YAML when placement or API responsiveness looks wrong.  
[9:00–10:00] This checklist is your pre-scale gate in real teams.

## Video close — fast validation

**What happens when you run this:**  
Re-run readiness script; wide lists for nodes and pods — recap only.

```bash
./scripts/check-large-cluster-readiness.sh
kubectl get nodes -o wide
kubectl get pods -o wide
```
