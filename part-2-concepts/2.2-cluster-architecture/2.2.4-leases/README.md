# 2.2.4 Leases

- Summary: Leases reduce heartbeat churn and support leader election, making them an important but often overlooked control-plane primitive.
- Content: Show how node heartbeats use Lease objects and how leader election uses similar mechanisms for coordination.
- Lab: Inspect leases in the cluster and correlate them with nodes or control-plane components.

## Assets

- `scripts/inspect-leases.sh`
- `yamls/lease-notes.yaml`
