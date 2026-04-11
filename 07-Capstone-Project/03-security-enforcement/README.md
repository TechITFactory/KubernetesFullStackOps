# 03 Security Enforcement

## Metadata
- Duration: `15 minutes`
- Difficulty: `Capstone`

## Learning Objective
- Lock down lateral network movement within the Capstone production tier.

## The Mission
An internal penetration testing team just flagged that any compromised container inside the cluster can ping the Redis database freely. You must instantly close the East-West traffic plane utilizing Zero-Trust Network Policies.

## Lab: Step-by-Step Practical

### Step 1 - Open directory
**Run:**
```bash
cd "$COURSE_DIR/07-Capstone-Project/03-security-enforcement"
```

### Step 2 - Lock the Database

**What happens when you run this:**
You deploy a NetworkPolicy targeting `app: redis`. It mathematically denies ALL traffic that does not physically originate from a Pod broadcasting the `app: frontend` label.

**Run:**
```bash
cat yamls/capstone-network-policy.yaml
kubectl apply -f yamls/capstone-network-policy.yaml
```

## Next Mission
[Phase 04: Observability and Scaling](../04-observability-verification/README.md)
