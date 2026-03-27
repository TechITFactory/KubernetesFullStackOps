# 2.2.8 Garbage Collection

- Summary: Garbage collection in Kubernetes depends on owner references, cascading deletion, and API lifecycle semantics.
- Content: Teach how dependents are cleaned up and why orphaned resources happen when ownership metadata is missing or changed.
- Lab: Create an owned resource and observe cascading cleanup.

## Assets

- `scripts/garbage-collection-demo.sh`
- `yamls/garbage-collection-demo.yaml`
