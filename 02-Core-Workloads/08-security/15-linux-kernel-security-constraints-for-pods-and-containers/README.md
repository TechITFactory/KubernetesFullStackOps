# Linux Kernel Security Constraints for Pods and Containers — teaching transcript

## Intro

**Linux** **kernel** **mechanisms** constrain containers: **capabilities** (**CAP_** drops), **seccomp** **profiles** (**RuntimeDefault** / **Localhost**), **AppArmor** / **SELinux** **profiles**, **user** **namespaces** (where supported), **readOnlyRootFilesystem**, and **allowPrivilegeEscalation: false**. **PSS** **restricted** encodes many of these defaults. **Profiles** must exist **on** **nodes**—**Pod** **spec** **references** **names** that **kubelet** / **runtime** **must** **resolve**.

**Prerequisites:** [2.8.14 API Bypass Risks](../14-kubernetes-api-server-bypass-risks/README.md); [2.8.2 PSS](../02-pod-security-standards/README.md).

## Flow of this lesson

```
  Pod securityContext + annotations
              │
              ▼
  kubelet + runtime → seccomp / AppArmor / SELinux / capabilities
              │
              ▼
  Kernel enforcement
```

**Say:**

**seccomp** **RuntimeDefault** is **one** **line** in **modern** **Pod** **specs**—huge **win** for **syscall** **surface**.

## Learning objective

- Name **capabilities**, **seccomp**, **AppArmor**, and **SELinux** as **layers** under **Pod** **securityContext**.
- Use **`kubectl explain`** for **seccompProfile** fields.

## Why this matters

**Container** **escape** **primitives** often **chain** **missing** **seccomp** **with** **CAP_SYS_ADMIN**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/02-Core-Workloads/08-security/15-linux-kernel-security-constraints-for-pods-and-containers" 2>/dev/null || cd .
```

## Step 1 — Apply notes ConfigMap

**What happens when you run this:**

Kernel constraints notes.

**Run:**

```bash
kubectl apply -f yamls/2-8-15-linux-kernel-security-constraints-for-pods-and-containers-notes.yaml
kubectl get cm -n kube-system 2-8-15-linux-kernel-security-constraints-for-pods-and-containers-notes -o name 2>/dev/null || true
```

**Expected:** ConfigMap `2-8-15-linux-kernel-security-constraints-for-pods-and-containers-notes` when allowed.

---

## Step 2 — Explain seccomp profile fields (read-only)

**What happens when you run this:**

**API** **documentation** for **Pod** **and** **container** **levels**.

**Run:**

```bash
kubectl explain pod.spec.securityContext.seccompProfile 2>/dev/null | head -n 25 || true
kubectl explain pod.spec.containers.securityContext.seccompProfile 2>/dev/null | head -n 20 || true
```

**Expected:** **type** **Localhost** / **RuntimeDefault** / **Unconfined** docs.

## Video close — fast validation

```bash
kubectl explain pod.spec.containers.securityContext.capabilities 2>/dev/null | head -n 20 || true
```

## Troubleshooting

- **Profile** **not** **found** → **node** **missing** **file** **path** for **LocalhostProfile**
- **SELinux** **denials** → **ausearch** / **audit2allow** on **node**
- **AppArmor** **not** **loaded** → **Ubuntu** vs **other** **distro** **differences**
- **`Forbidden` notes** → offline YAML

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/2-8-15-linux-kernel-security-constraints-for-pods-and-containers-notes.yaml` | Notes ConfigMap |

## Cleanup

```bash
kubectl delete configmap 2-8-15-linux-kernel-security-constraints-for-pods-and-containers-notes -n kube-system --ignore-not-found 2>/dev/null || true
```

## Next

[2.8.16 Security Checklist](../16-security-checklist/README.md)
