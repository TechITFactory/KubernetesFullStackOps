# 1.2.3 Turnkey Cloud Solutions

- **Summary**: Evaluate managed Kubernetes offerings — EKS, GKE, AKS, and others — to determine when the operational trade-offs favour managed over self-managed clusters.
- **Content**: What managed Kubernetes does and does not handle, the decision framework, provider comparison, cloud CLI readiness check.
- **Lab**: Run `cloud-readiness-check.sh` to confirm tooling, review `turnkey-cloud-options.yaml` against your environment, record your platform decision with rationale.

## Files

| Path | Purpose |
|------|---------|
| `scripts/cloud-readiness-check.sh` | Checks cloud CLIs (aws, gcloud, az), authentication state, and kubectl context |
| `yamls/turnkey-cloud-options.yaml` | Structured comparison of managed Kubernetes providers — use as a decision record |

## Quick Start

```bash
# Check your cloud tooling
./scripts/cloud-readiness-check.sh

# Review provider trade-offs
cat yamls/turnkey-cloud-options.yaml
```

---

## Transcript — 10-Minute Lesson

### [0:00–0:45] Hook

Everything in sections 1.2.1 and 1.2.2 was about building Kubernetes yourself — installing runtimes, running kubeadm, managing etcd, configuring kubelet. That is real, valuable knowledge. It is also real, ongoing operational work.

For some teams, that work is the point — they want full control, and they have the operational capacity. For other teams, that work is a distraction from shipping their product.

This section is an honest look at the other option: let a cloud provider run the control plane for you.

---

### [0:45–2:15] What "Managed Kubernetes" Actually Means

When a cloud provider offers managed Kubernetes (EKS, GKE, AKS, DigitalOcean Kubernetes, etc.), they are taking responsibility for the control plane:

**What they manage:**
- API server, controller-manager, scheduler — provisioned, monitored, auto-repaired.
- etcd — backed up, secured, scaled. You never touch it.
- Control-plane upgrades — one click or one API call.
- Control-plane certificates — auto-rotated.
- Multi-AZ control-plane replication — typically included.

**What you still manage:**
- **Worker nodes** — your VMs, your patching, your runtime configuration. (Some providers offer managed node groups that reduce this.)
- **Cluster add-ons** — Ingress controllers, cert-manager, monitoring, logging.
- **Application workloads** — everything you deploy.
- **Networking** — VPC design, security groups, CNI configuration.
- **RBAC and policies** — who can access what.
- **Cost** — cloud resources, data transfer, load balancers.

**The key trade-off**: you give up control of the control plane (and visibility into it — you cannot SSH into the API server), and in return you stop paying the operational cost of running it.

---

### [2:15–3:30] The Real Cost of Self-managed

The kubeadm path is powerful and educational. It is also non-trivial to operate at scale:

- **Upgrades**: each upgrade requires careful planning — drain nodes, upgrade kubeadm, upgrade control plane, upgrade workers, one minor version at a time. On a 50-node cluster, this is a half-day operation.
- **Certificate rotation**: control-plane certificates expire (usually 1 year). Expired certificates crash the cluster.
- **etcd backups**: must be automated, tested, and stored off-cluster. A missed backup means no recovery from accidental deletion.
- **Node OS patching**: kernel updates, security patches — all require node drains and reboots.
- **On-call burden**: when a control-plane node fails at 3am, someone pages.

For a team of 3 engineers shipping a product, this operational overhead may consume 20–30% of engineering capacity. That is capacity not spent building the product.

**Managed Kubernetes returns that capacity.**

---

### [3:30–5:00] Provider Comparison

| Provider | Service | Control Plane Cost | Node Flexibility | Managed Nodes |
|----------|---------|-------------------|-----------------|---------------|
| **AWS EKS** | Elastic Kubernetes Service | ~$0.10/hr per cluster | Any EC2 instance type | Yes (EKS Managed Node Groups, Fargate) |
| **Google GKE** | Google Kubernetes Engine | Free for Standard, ~$0.10/hr for Autopilot | Any GCE instance type | Yes (Autopilot, Standard node pools) |
| **Azure AKS** | Azure Kubernetes Service | Free control plane | Any VM size | Yes (VMSS node pools) |
| **DigitalOcean DOKS** | DigitalOcean Kubernetes | Free control plane | Droplet sizes | Yes |
| **Civo** | Civo Kubernetes | Free control plane | Civo instances | Yes |

**GKE Autopilot** is the most hands-off option — Google manages nodes as well as the control plane. You pay per pod resource request, not per node. No node patching, no node scaling — just deploy workloads.

**EKS + Fargate** is similar — serverless nodes. No EC2 instances to manage. Pods run in isolated micro-VMs.

---

### [5:00–6:30] Decision Framework

```
Is your team smaller than 5 engineers?
├── Yes → Strong case for managed. Self-managed control plane ops will be a significant burden.
└── No  → Is Kubernetes itself your product (Kubernetes distro, platform team)?
          ├── Yes → Self-managed with kubeadm or a distribution.
          └── No  → Do you have compliance requirements that restrict cloud usage?
                    ├── Yes → Self-managed on-premise or in a private cloud.
                    └── No  → Do you need custom control-plane configuration?
                              ├── Yes → Self-managed (or check if your provider's managed offering supports it).
                              └── No  → Managed Kubernetes. Pick your cloud provider.
```

**Also consider:**
- **Existing cloud spend**: if you are already on AWS, EKS has the least friction.
- **Multi-cloud or cloud-agnostic requirement**: managed services are provider-specific; self-managed with kubeadm or k0s runs anywhere.
- **Cost at scale**: managed control planes add a fixed per-cluster cost. At 50+ clusters, this adds up. Large enterprises sometimes run their own control planes to avoid it.

---

### [6:30–7:30] What You Still Learn Here Applies

Choosing managed Kubernetes does not make this course less relevant. Everything you learn about Deployments, Services, Ingress, RBAC, storage, networking, monitoring — all of it applies identically on EKS, GKE, or AKS.

The Kubernetes API is standardised. A Deployment YAML that works on a kubeadm cluster works unchanged on EKS. A ConfigMap is a ConfigMap everywhere.

The difference is only in the infrastructure layer below the API. Understanding what kubeadm does — generating certificates, bootstrapping etcd, configuring kubelet — makes you a better operator of managed Kubernetes too. You understand what the cloud provider is doing for you, which makes you better at diagnosing problems when they occur.

---

### [7:30–8:30] Cloud CLI Readiness Check

`cloud-readiness-check.sh` runs before you create a managed cluster:

```bash
./scripts/cloud-readiness-check.sh
```

It checks:
- **CLI tools**: `aws`, `gcloud`, `az`, `kubectl`, `helm`, `terraform`, `eksctl` — reports which are installed and their versions.
- **Authentication**: runs a lightweight auth check for each cloud CLI — catches expired credentials or missing profiles before you run a 10-minute cluster provisioning command that fails at the last step.
- **kubectl context**: shows your current context so you know where commands will go.

Run this every time you start work on a cluster provisioning task. Expired cloud credentials are the most common cause of "why did this fail?" in infrastructure automation.

---

### [8:30–9:15] Real World — How Companies Actually Choose

**Startups (< 20 engineers)**: almost universally start on managed Kubernetes. EKS or GKE. The operational overhead of self-managed is not justified. As they grow, they may invest in a platform team that builds internal tooling on top of managed services.

**Mid-size companies (20–200 engineers)**: often have a small platform team (3–6 engineers) that manages Kubernetes infrastructure. They typically use managed control planes but run custom node pools with tuned instance types, custom AMIs, and additional tooling.

**Large enterprises (200+ engineers)**: split. Companies with strong cloud-native culture often run managed. Companies with existing data-centre infrastructure (finance, healthcare, retail) often run self-managed on-premise with OpenShift or Rancher. Some run both — managed in the cloud, self-managed on-premise.

**Platform engineering teams**: often run self-managed because they are the product. Their job is to give other teams Kubernetes. Using managed Kubernetes as the foundation (running kubeadm on top of managed VMs, or using EKS as a base and adding custom tooling) is increasingly common.

---

### [9:15–10:00] Recap

- **Managed Kubernetes** = cloud provider runs the control plane. You manage worker nodes, add-ons, and workloads.
- **Trade-off**: give up control and visibility of the control plane; get back operational capacity.
- **What you still manage**: worker nodes, networking, RBAC, add-ons, cost.
- **Decision drivers**: team size, compliance requirements, multi-cloud needs, existing cloud spend.
- **Kubernetes API is portable** — skills learned here apply identically on any managed offering.
- **cloud-readiness-check.sh** — check CLIs and auth before running provisioning commands.

This concludes Part 1 of the course. In Part 2 we move into Kubernetes Concepts — the mental model behind every resource you create and manage.

## Video close — fast validation

```bash
./scripts/cloud-readiness-check.sh
kubectl config current-context
kubectl get nodes -o wide 2>/dev/null || echo "No cluster context or API unreachable — fix auth/context before provisioning."
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common managed-cluster access, auth, and networking readiness failures.
