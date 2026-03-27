# 2.2.2 Communication between Nodes and the Control Plane

- Summary: Node-to-control-plane communication is mostly kubelet-driven and API-based, which is central to understanding access patterns and security boundaries.
- Content: Cover kubelet registration, heartbeats, API server access, certificate use, and how node agents avoid direct dependency on the scheduler or controller-manager.
- Lab: Inspect node status updates, leases, and kubelet-facing communication surfaces.

## Assets

- `scripts/inspect-node-control-plane-communication.sh`
- `yamls/node-control-plane-flow.yaml`
