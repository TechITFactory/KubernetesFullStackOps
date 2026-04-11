# 3.10 Access Applications in a Cluster

- Objective: Access and debug applications reliably across local and cloud clusters.
- Outcomes:
  - Use dashboard, contexts, services, port-forwarding, and DNS access patterns.
  - Validate in-cluster and external access paths.
  - Troubleshoot common connectivity failures fast.
- Notes:
  - Practical-only command flows.
  - Linux-focused examples.
  - EKS mapping included in lesson notes where relevant.

## Children

- 3.10.1 Deploy and Access the Kubernetes Dashboard
- 3.10.2 Accessing Clusters
- 3.10.3 Configure Access to Multiple Clusters
- 3.10.4 Use Port Forwarding to Access Applications in a Cluster
- 3.10.5 Use a Service to Access an Application in a Cluster
- 3.10.6 Connect a Frontend to a Backend Using Services
- 3.10.7 Create an External Load Balancer
- 3.10.8 List All Container Images Running in a Cluster
- 3.10.9 Communicate Between Containers in the Same Pod Using a Shared Volume
- 3.10.10 Configure DNS for a Cluster
- 3.10.11 Access Services Running on Clusters

## Access Baseline Checks

```bash
kubectl config current-context
kubectl get nodes
kubectl get svc -A
```
