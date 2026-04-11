## Proposed Restructuring Plan


### 01-Local-First-Operations

- **1.1-learning-environment** -> **01-learning-environment**
  - 1.1.1-minikube-setup-and-configuration -> 01-minikube-setup
  - 1.1.2-kind-kubernetes-in-docker -> 02-kind-in-docker
  - 1.1.3-local-development-clusters -> 03-local-dev-clusters
- **1.2-production-environment** -> **02-production-environment**
- **1.3-best-practices** -> **03-best-practices**
  - 1.3.1-considerations-for-large-clusters -> 01-large-clusters
  - 1.3.2-running-in-multiple-zones -> 02-multiple-zones
  - 1.3.3-validate-node-setup -> 03-validate-node-setup
  - 1.3.4-enforcing-pod-security-standards -> 04-pod-security-standards
  - 1.3.5-pki-certificates-and-requirements -> 05-pki-certificates

### 02-Core-Workloads

We will rename the major 2.X folders to 01-13. Inside *each* of those, we will pull all deeply nested lessons (e.g. 2.1.2.1) up to sit flat alongside their siblings, and renumber them sequentially 01 to N.
- **2.10-scheduling-preemption-and-eviction** -> **01-scheduling-preemption-and-eviction**
- **2.11-cluster-administration** -> **02-cluster-administration**
- **2.12-windows-in-kubernetes** -> **03-windows-in-kubernetes**
- **2.13-extending-kubernetes** -> **04-extending-kubernetes**
- **2.1-overview** -> **05-overview**
- **2.2-cluster-architecture** -> **06-cluster-architecture**
- **2.3-containers** -> **07-containers**
- **2.4-workloads** -> **08-workloads**
- **2.5-services-load-balancing-and-networking** -> **09-services-load-balancing-and-networking**
- **2.6-storage** -> **10-storage**
- **2.7-configuration** -> **11-configuration**
- **2.8-security** -> **12-security**
- **2.9-policies** -> **13-policies**
