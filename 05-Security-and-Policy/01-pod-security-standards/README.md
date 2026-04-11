# 01 Pod Security Standards

## Metadata
- Duration: `15 minutes`
- Difficulty: `Beginner`
- Practical/Theory: `60/40`
- Tested on Kubernetes: `v1.30`

## Learning Objective
By the end of this lesson, you will be able to:
- Enforce cluster-wide restricted parameters to permanently reject vulnerable workloads.
- Prove that privileged escalations are blocked structurally inside Kubernetes natively.

## Why This Matters in Real Jobs
If a hacker exploits a frontend container, their next move is "Privilege Escalation"—trying to break out of the container to control the literal worker node. Pod Security Standards (PSS) act as an automated bouncer, refusing to schedule any Pod that requests dangerous Linux capabilities (like running as Root or capturing Host networks).

## Concepts (Short Theory)
- **Privileged Pod:** A container running with nearly unlimited access to the host operating system. Extremely dangerous.
- **Pod Security Standards (PSS):** Built-in Kubernetes profiles (`Privileged`, `Baseline`, `Restricted`).
- **Enforce Mode:** The namespace label that strictly rejects any non-compliant pods during API submission.

## Lab: Step-by-Step Practical

### Step 1 - Open directory
**Run:**
```bash
cd "$COURSE_DIR/05-Security-and-Policy/01-pod-security-standards"
```

### Step 2 - Create the Hardened Environment

**What happens when you run this:**
You apply a `Namespace` that has specific `pod-security.kubernetes.io/enforce: restricted` labels natively attached.

**Run:**
```bash
kubectl apply -f yamls/secure-namespace.yaml
```

### Step 3 - Attempt a Malicious Deployment

**What happens when you run this:**
You try to launch `bad-pod.yaml`. It requests `privileged: true` and `runAsUser: 0` (root).

**Say:**
Because the namespace is strictly restricted, the Kubernetes API Server physically refuses to allow this Pod into the system.

**Run:**
```bash
kubectl apply -f yamls/bad-pod.yaml
```

### Step 4 - Validate Compliance

**What happens when you run this:**
You apply `good-pod.yaml`. This Pod explicitly drops ALL unused Linux capabilities and runs strictly as a non-root user. The API accepts it seamlessly.

**Run:**
```bash
kubectl apply -f yamls/good-pod.yaml
kubectl get pods -n hardened-env
```

## Expected Output
Applying the bad pod must result in a fatal `Error from server (Forbidden): violates PodSecurity "restricted:latest"`. Applying the good pod must yield `compliant-pod created`.

## Next Lesson
[02 RBAC Design Patterns](../02-rbac-design-patterns/README.md)
