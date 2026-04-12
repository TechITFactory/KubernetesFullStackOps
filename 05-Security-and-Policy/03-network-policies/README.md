# Network policies — teaching transcript

## Intro

**Without** **NetworkPolicies**, **Pod** **networking** **is** **typically** **open** **east-west** **inside** **the** **cluster** **(CNI-dependent)**. **A** **default-deny** **policy** **selects** **all** **Pods** **in** **a** **namespace** **and** **blocks** **ingress** **and** **egress** **until** **you** **add** **narrow** **allow** **rules**. **This** **repo’s** **samples** **target** **`namespace: default`** **—** **use** **only** **on** **disposable** **lab** **clusters** **or** **copy** **them** **to** **a** **dedicated** **namespace** **first**.

**Prerequisites:** [5.2 RBAC design patterns](../02-rbac-design-patterns/README.md); **CNI** **that** **enforces** **`NetworkPolicy`** **(Calico**, **Cilium**, **etc.)**.

## Flow of this lesson

```
  default-deny (podSelector: {}) → all Pods isolated
              │
              ▼
  allow-frontend-to-db → ingress to app=database:5432 from app=frontend
              │
              ▼
  Validate with kubectl describe / test traffic (optional)
```

**Say:**

**If** **nothing** **breaks** **after** **`apply`**, **your** **CNI** **might** **not** **enforce** **policy** **—** **confirm** **before** **you** **claim** **zero-trust**.

## Learning objective

- **Interpret** **`podSelector: {}`** **default** **deny** **and** **a** **targeted** **ingress** **allow** **rule**.
- **Apply** **policies** **from** **`yamls/`** **and** **state** **what** **traffic** **they** **permit**.

## Why this matters

**A** **compromised** **frontend** **should** **not** **reach** **every** **database** **port** **by** **default** **—** **NetworkPolicy** **is** **the** **first** **Kubernetes-native** **wall**.

## One-time setup

```bash
cd "$(git rev-parse --show-toplevel 2>/dev/null)/05-Security-and-Policy/03-network-policies" 2>/dev/null || cd .
```

## Step 1 — Inspect default deny

**What happens when you run this:**

**You** **review** **`default-deny-all`**, **which** **selects** **every** **Pod** **in** **`default`** **and** **denies** **all** **ingress** **and** **egress**.

**Say:**

**Applying** **this** **to** **`default` on** **a** **shared** **dev** **cluster** **can** **break** **DNS** **and** **control** **traffic** **—** **treat** **as** **destructive**.

**Run:**

```bash
cat yamls/deny-all.yaml
```

**Expected:** **`NetworkPolicy`** **with** **`podSelector: {}`**, **`Ingress`**, **`Egress`**.

---

## Step 2 — Apply default deny (lab only)

**What happens when you run this:**

**Enforces** **the** **policy** **in** **`default`**.

**Run:**

```bash
kubectl apply -f yamls/deny-all.yaml
kubectl get networkpolicy -n default
```

**Expected:** **`default-deny-all`** **listed**.

---

## Step 3 — Add a targeted allow

**What happens when you run this:**

**Allows** **ingress** **to** **Pods** **labeled** **`app: database`** **on** **port** **`5432`** **only** **from** **Pods** **labeled** **`app: frontend`**.

**Run:**

```bash
cat yamls/allow-frontend-to-db.yaml
kubectl apply -f yamls/allow-frontend-to-db.yaml
kubectl get networkpolicy -n default
```

**Expected:** **`allow-frontend-to-db`** **present** **alongside** **deny** **policy**.

## Video close — fast validation

**What happens when you run this:**

**Removes** **both** **policies** **from** **`default`**.

**Run:**

```bash
kubectl delete -f yamls/allow-frontend-to-db.yaml --ignore-not-found
kubectl delete -f yamls/deny-all.yaml --ignore-not-found
```

**Expected:** **Policies** **gone**.

## Troubleshooting

- **Policies** **exist** **but** **traffic** **unchanged** → **CNI** **does** **not** **support** **`NetworkPolicy`** **enforcement**
- **Cluster** **breaks** **after** **deny-all** → **delete** **policy** **or** **add** **explicit** **allows** **for** **kube-dns** **and** **the** **API**
- **Wrong** **namespace** → **edit** **`metadata.namespace`** **in** **copies** **before** **apply**

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `yamls/deny-all.yaml` | **Default** **deny** **all** **(namespace** **`default`)** |
| `yamls/allow-frontend-to-db.yaml` | **Allow** **frontend** **→** **database** **ingress** |

## Cleanup

```bash
kubectl delete -f yamls/allow-frontend-to-db.yaml --ignore-not-found 2>/dev/null || true
kubectl delete -f yamls/deny-all.yaml --ignore-not-found 2>/dev/null || true
```

## Next

[5.4 Admission controls](../04-admission-controls/README.md)
