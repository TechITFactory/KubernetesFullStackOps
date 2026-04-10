# 3.3 Configure Pods and Containers

- Objective: Configure pod/container runtime behavior for security, reliability, and scheduling.
- Outcomes:
  - Set resources, probes, security contexts, and placement constraints.
  - Use storage, config, and service account patterns correctly.
  - Diagnose runtime issues with pod-level signals.
- Notes:
  - Practical-focused with command and validation for each pattern.
  - Keep security defaults strong by default.
  - Use Linux-only examples for consistency.

## Children

- 3.3.1 Assign Memory Resources to Containers and Pods
- 3.3.2 Assign CPU Resources to Containers and Pods
- 3.3.3 Assign Devices to Pods and Containers
- 3.3.4 Assign Pod-level CPU and Memory Resources
- 3.3.5 Configure GMSA for Windows Pods and Containers
- 3.3.6 Resize CPU and Memory Resources Assigned to Containers
- 3.3.7 Resize CPU and Memory Resources Assigned to Pods
- 3.3.8 Configure RunAsUserName for Windows Pods and Containers
- 3.3.9 Create a Windows HostProcess Pod
- 3.3.10 Configure Quality of Service for Pods
- 3.3.11 Assign Extended Resources to a Container
- 3.3.12 Configure a Pod to Use a Volume for Storage
- 3.3.13 Configure a Pod to Use a PersistentVolume for Storage
- 3.3.14 Configure a Pod to Use a Projected Volume for Storage
- 3.3.15 Configure a Security Context for a Pod or Container
- 3.3.16 Configure Service Accounts for Pods
- 3.3.17 Pull an Image from a Private Registry
- 3.3.18 Configure Liveness, Readiness and Startup Probes
- 3.3.19 Assign Pods to Nodes
- 3.3.20 Assign Pods to Nodes Using Node Affinity
- 3.3.21 Configure Pod Initialization
- 3.3.22 Attach Handlers to Container Lifecycle Events
- 3.3.23 Configure a Pod to Use a ConfigMap
- 3.3.24 Share Process Namespace between Containers in a Pod
- 3.3.25 Use a User Namespace With a Pod
- 3.3.26 Use an Image Volume With a Pod
- 3.3.27 Create Static Pods
- 3.3.28 Translate a Docker Compose File to Kubernetes Resources
- 3.3.29 Enforce Pod Security Standards by Configuring the Built-in Admission Controller
- 3.3.30 Enforce Pod Security Standards with Namespace Labels
- 3.3.31 Migrate from PodSecurityPolicy to the Built-In PodSecurity Admission Controller

## Module Validation

```bash
kubectl get pods -A
kubectl describe pod <pod-name> -n <namespace>
kubectl get events -A --sort-by=.lastTimestamp | tail -n 30
```
