# Security — teaching transcript

## Intro

Kubernetes **security** spans **identity** (who calls the API), **authorization** (what they may do), **admission** (what objects may exist), **Pod hardening** (PSS/PSA, capabilities, seccomp), **node** posture (Linux and Windows), **secrets** handling, and **multi-tenant** isolation. This module mirrors that stack: **cloud-native** framing, **Pod Security Standards** and **admission**, **ServiceAccounts** and **RBAC**, platform **hardening** topics, **bypass** awareness, and **checklists** for ops and applications. Nothing here replaces your organization’s **threat model**—it gives you **kubectl**-grounded vocabulary and where controls live.

**Prerequisites:** [2.7 Configuration](../07-configuration/README.md) (Secrets, RBAC-related kubeconfig); [02-Core-Workloads entry](../README.md).

## Flow of this lesson

```
  Cloud-native / 4C framing
              │
              ▼
  Pod Security Standards ──► Pod Security Admission (namespace labels)
              │
              ▼
  ServiceAccounts + RBAC + API access patterns
              │
              ▼
  Node security (Linux / Windows) + hardening guides
              │
              ▼
  Bypass risks + kernel constraints + checklists
```

**Say:**

I pair **PSS labels** on **namespaces** with **`auth can-i`** checks—policy on paper means nothing if RBAC still allows **`pods/exec`**.

## Learning objective

- Navigate **2.8.1–2.8.17** in order (or jump to checklists for audits) and run each lesson’s **notes** YAML plus **inspect** scripts where they exist.
- Relate **PSA**, **RBAC**, and **ServiceAccount** defaults to real **incident** and **compliance** questions.

## Why this matters

Misconfigured **defaults** (wide **cluster-admin**, **privileged** Pods, **long-lived tokens**) are how clusters become **news**.

## Children (suggested order)

1. [2.8.1 Cloud Native Security](01-cloud-native-security/README.md)
2. [2.8.2 Pod Security Standards](02-pod-security-standards/README.md)
3. [2.8.3 Pod Security Admission](03-pod-security-admission/README.md)
4. [2.8.4 Service Accounts](04-service-accounts/README.md)
5. [2.8.5 Pod Security Policies](05-pod-security-policies/README.md)
6. [2.8.6 Security for Linux Nodes](06-security-for-linux-nodes/README.md)
7. [2.8.7 Security for Windows Nodes](07-security-for-windows-nodes/README.md)
8. [2.8.8 Controlling Access to the Kubernetes API](08-controlling-access-to-the-kubernetes-api/README.md)
9. [2.8.9 Role Based Access Control Good Practices](09-role-based-access-control-good-practices/README.md)
10. [2.8.10 Good Practices for Kubernetes Secrets](10-good-practices-for-kubernetes-secrets/README.md)
11. [2.8.11 Multi-tenancy](11-multi-tenancy/README.md)
12. [2.8.12 Hardening Guide — Authentication Mechanisms](12-hardening-guide-authentication-mechanisms/README.md)
13. [2.8.13 Hardening Guide — Scheduler Configuration](13-hardening-guide-scheduler-configuration/README.md)
14. [2.8.14 Kubernetes API Server Bypass Risks](14-kubernetes-api-server-bypass-risks/README.md)
15. [2.8.15 Linux Kernel Security Constraints for Pods and Containers](15-linux-kernel-security-constraints-for-pods-and-containers/README.md)
16. [2.8.16 Security Checklist](16-security-checklist/README.md)
17. [2.8.17 Application Security Checklist](17-application-security-checklist/README.md)

## Module wrap — quick validation

**What happens when you run this:** Read-only snapshot of namespaces, RBAC hints, and PSA-related labels.

**Say:**

Before filming **2.8.3**, I capture **`kubectl get ns --show-labels`** so viewers see **enforce** vs **audit** labels in the wild.

```bash
kubectl get ns --show-labels 2>/dev/null | head -n 25
kubectl get clusterrolebinding 2>/dev/null | head -n 15 || true
kubectl auth can-i --list 2>/dev/null | head -n 25 || true
```

## Troubleshooting

- **`auth can-i --list` forbidden** → your user lacks **selfsubjectrulesreview**—use **admin** read-only elsewhere or **`can-i`** per verb
- **No PSA labels** → cluster not wired or legacy **PSP** only—narrate migration
- **Overwhelming ClusterRoleBindings** → filter with **`grep`** or **`jq`**
- **Wrong cluster** → **`kubectl config current-context`**

## Next

[2.9 Policies](../09-policies/README.md)
