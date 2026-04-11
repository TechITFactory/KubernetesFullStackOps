# 03 Network Policies

## Metadata
- Duration: `15 minutes`
- Difficulty: `Intermediate`
- Practical/Theory: `60/40`
- Tested on Kubernetes: `v1.30` (Requires accurate CNI like Calico/Cilium)

## Learning Objective
By the end of this lesson, you will be able to:
- Establish a Default-Deny universal firewall within a namespace.
- Poke exact, targeted holes allowing specific frontend pods to communicate with specific backend databases.

## Why This Matters in Real Jobs
By default, Kubernetes cluster network is entirely flat—every Pod can natively ping every other Pod. If a hacker breaches your public-facing frontend Pod, they have unrestricted internal network access to scan your databases unless you strictly wall them off using Network Policies.

## Lab: Step-by-Step Practical

### Step 1 - Open directory
**Run:**
```bash
cd "$COURSE_DIR/05-Security-and-Policy/03-network-policies"
```

### Step 2 - Establish Zero Trust

**What happens when you run this:**
You deploy a `NetworkPolicy` mapping to `podSelector: {}` matching ALL pods. It enforces `Ingress` and `Egress` blocks, instantly sealing the entire namespace in a vacuum.

**Run:**
```bash
cat yamls/deny-all.yaml
kubectl apply -f yamls/deny-all.yaml
```

### Step 3 - Open the Database Port

**What happens when you run this:**
You apply an explicitly targeted policy that allows traffic targeting port `5432` ONLY if the traffic completely originated from a Pod labeled `app: frontend`.

**Run:**
```bash
cat yamls/allow-frontend-to-db.yaml
kubectl apply -f yamls/allow-frontend-to-db.yaml
```

## Next Lesson
[04 Admission Controls](../04-admission-controls/README.md)
