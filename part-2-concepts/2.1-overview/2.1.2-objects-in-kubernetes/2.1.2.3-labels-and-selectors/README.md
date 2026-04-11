# 2.1.2.3 Labels and Selectors — teaching transcript

## Intro

Labels are the connective tissue of Kubernetes.

A Service finds its pods through labels. A Deployment owns its ReplicaSet through labels. `kubectl get` lets you filter by labels. Monitoring tools, service meshes, and cost allocation tools all use labels to group and query resources. If you don't label things consistently, nothing works the way you expect.

A **label** is a key-value pair in `metadata.labels`. A **selector** is a query that matches objects by those pairs. Services have a `selector:` field. Deployments have a `selector:` field. `kubectl get -l` uses them. Understanding how selectors work — and when they can silently match the wrong thing — is one of the most important debugging skills in Kubernetes.

**Prerequisites:** [Part 1](../../../../part-1-getting-started/README.md).

**Teaching tip:** `scripts/query-label-selectors.sh` only queries — apply the YAML first or it returns empty results.

---

## Flow of this lesson

**Say:**
Three steps. Deploy a workload with labels, wait for it to be ready, then query it using label selectors to see how targeting works.

```
  [ Step 1 ]          [ Step 2 ]            [ Step 3 ]
  Apply demo   →      Wait for      →       Query with
  workload            rollout               label selectors
```

---

## Step 1 — Apply the demo workload

**What happens when you run this:**
`kubectl apply -f yamls/labels-and-selectors-demo.yaml` creates a Deployment `demo-web` and a Service in the `default` namespace. The Service's `selector:` matches the Deployment's pod template labels. Declarative; safe to re-run.

**Say:**
Look at the manifest if you open it — the Service's `selector:` matches the pod template's `labels:`. That match is what makes traffic from the Service reach the pods. If those labels drift — if someone edits the pod template but forgets to update the Service selector — the Service has zero endpoints and traffic silently drops.

**Run:**

```bash
kubectl apply -f yamls/labels-and-selectors-demo.yaml
```

**Expected:**
Deployment and Service created or unchanged.

---

## Step 2 — Wait for the Deployment

**What happens when you run this:**
`kubectl wait --for=condition=available deployment/demo-web` blocks until the Deployment's `Available` condition is true or the timeout is reached. `chmod +x scripts/*.sh` makes the query script executable.

**Say:**
I always wait for the rollout before querying. If I query while pods are still starting, the selector results are misleading — the endpoint might exist but pods aren't ready yet.

**Run:**

```bash
kubectl wait --for=condition=available deployment/demo-web --timeout=120s
chmod +x scripts/*.sh
```

**Expected:**
`deployment.apps/demo-web condition met`.

---

## Step 3 — Query with label selectors

**What happens when you run this:**
`query-label-selectors.sh` runs several `kubectl get` commands with `-l` selectors to show how label matching works — pods matching app label, services matching tier, cross-resource queries. All read-only.

**Say:**
The `-l` flag is the selector syntax. `app=demo-web` is an equality selector. `app in (demo-web, other-app)` is a set-based selector. `!deprecated` matches objects that do NOT have the `deprecated` key. You'll use all three forms in real clusters.

**Run:**

```bash
./scripts/query-label-selectors.sh
```

**Expected:**
Multiple query results printed — pods and services matching course labels.

---

## Selector types

**Equality-based** — the most common:
```bash
kubectl get pods -l app=demo-web
kubectl get pods -l app!=legacy
```

**Set-based** — for multiple values or negation:
```bash
kubectl get pods -l 'app in (demo-web, api)'
kubectl get pods -l 'tier notin (frontend)'
kubectl get pods -l '!deprecated'
```

**In manifests**, Services and Deployments use `matchLabels` for equality and `matchExpressions` for set-based:
```yaml
selector:
  matchLabels:
    app: demo-web
  matchExpressions:
    - key: tier
      operator: In
      values: [frontend]
```

**The selector trap:** Deployment selectors are **immutable** after creation. If you apply a Deployment with a different `selector:`, it fails with an immutable field error. You must delete and recreate the Deployment. This is the most common source of "cannot update Deployment" errors during label refactoring.

---

## Troubleshooting

- **Service has zero endpoints** → `kubectl describe svc demo-web` — check `Endpoints:` line; if empty, the selector doesn't match any pod labels; compare `kubectl get pods --show-labels` with the Service `selector:`
- **`kubectl get -l` returns nothing** → check for typos; label keys and values are case-sensitive; `App` ≠ `app`
- **Deployment selector immutable error** → delete the Deployment (`kubectl delete deploy demo-web`) then re-apply the manifest with the new selector
- **`query-label-selectors.sh` returns empty** → apply the demo manifest first (Step 1) before running the script

---

## Learning objective

- Explain how Service selectors connect to pod template labels.
- Use `-l` with equality and set-based selectors in `kubectl get`.
- Describe why Deployment selectors are immutable and what to do when you need to change them.

## Why this matters

Labels are the query language of Kubernetes. Every tool that interacts with your cluster — monitoring, service mesh, cost allocation, CI/CD — uses labels to find and group resources. Inconsistent labels mean broken dashboards, misconfigured routing, and billing reports that don't add up. Consistent labels from day one pay dividends across every operational tool you'll ever add.

---

## Video close — fast validation

**What happens when you run this:**
Selector-based get, then delete the demo manifest to clean up.

**Say:**
The selector query confirms the label chain is intact — Service, Deployment, pods all share the same label values. Then I clean up with `kubectl delete -f` using the same manifest that created the objects.

```bash
kubectl get deploy,svc -n default -l app.kubernetes.io/part-of=overview-module
kubectl delete -f yamls/labels-and-selectors-demo.yaml --ignore-not-found
```

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `scripts/query-label-selectors.sh` | Multiple label selector queries |
| `yamls/labels-and-selectors-demo.yaml` | Demo Deployment + Service |
| `yamls/failure-troubleshooting.yaml` | Selector mismatch and empty endpoint hints |

---

## Next

[2.1.2.4 Namespaces](../2.1.2.4-namespaces/README.md)
