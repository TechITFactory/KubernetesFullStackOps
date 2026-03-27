# 2.1.2.8 Owners and Dependents

- Summary: Owner references define garbage-collection relationships and help Kubernetes understand what should be cleaned up together.
- Content: This subsection explains how Deployments own ReplicaSets, ReplicaSets own Pods, and how cascading deletion works.
- Lab: Apply the sample Deployment, inspect owner references, then delete the parent object.

## Assets

- `scripts/show-owner-references.sh`
- `yamls/owner-reference-demo.yaml`
