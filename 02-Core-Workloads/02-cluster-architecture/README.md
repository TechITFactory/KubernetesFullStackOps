# Cluster Architecture — teaching transcript





## Intro





Every action you take with `kubectl` flows through a defined architecture: the API server receives it, etcd persists it, controllers reconcile toward it, and kubelets on nodes execute it. Understanding this flow means you can trace any failure — from a stuck pod to a node going `Unknown` — back to the component responsible.





This module walks each architectural piece in order: nodes and their agents, the communication paths between nodes and the control plane, the controller reconcile loop, the Lease heartbeat mechanism, cloud provider integration, cgroup resource isolation, self-healing behavior, and garbage collection.





**Prerequisites:** [Part 1](../../01-Local-First-Operations/README.md); finish [2.1 Overview](../01-overview/README.md) first if you want the vocabulary fresh.





---





## Flow of this module





```


  You (kubectl)


       │


       ▼


  API server ◀────────────────────────────────────┐


       │                                           │


       ├──▶ etcd (persists state)                  │


       │                                           │


       ├──▶ Controllers (reconcile loop)           │


       │         └──▶ API server (write actions)   │


       │                                           │


       └──▶ kubelet (on each node)                 │


                 ├──▶ CRI runtime (run containers) │


                 └──▶ Lease (heartbeat) ───────────└


```





**Say:** "Everything goes through the API server. Controllers read desired state from it and write back actual state. kubelets read their pod assignments from it and write node status back. Leases are the heartbeat that tells the control plane a node is still alive. When you understand this loop, you understand why almost every Kubernetes failure leaves evidence in `kubectl describe` or `kubectl get events`."





---





## Children (work in order)





- [2.2.1 Nodes](01-nodes/README.md)


- [2.2.2 Communication between nodes and the control plane](02-communication-between-nodes-and-the-control-plane/README.md)


- [2.2.3 Controllers](03-controllers/README.md)


- [2.2.4 Leases](04-leases/README.md)


- [2.2.5 Cloud controller manager](05-cloud-controller-manager/README.md)


- [2.2.6 About cgroup v2](06-about-cgroup-v2/README.md)


- [2.2.7 Kubernetes self-healing](07-kubernetes-self-healing/README.md)


- [2.2.8 Garbage collection](08-garbage-collection/README.md)


- [2.2.9 Mixed version proxy](09-mixed-version-proxy/README.md)





---





## Module wrap — quick validation





**What happens when you run this:**


Nodes; node heartbeat Leases; kube-system pods; recent events — read-only triage of the full architectural picture.





**Say:** "These four commands give me a complete architectural snapshot: which nodes are ready, when they last sent a heartbeat, which control-plane pods are running, and what events have fired recently. If anything in the module left the cluster in a bad state, it shows up here."





```bash


kubectl get nodes -o wide


kubectl get lease -n kube-node-lease


kubectl get pods -n kube-system -o wide


kubectl get events -A --sort-by=.lastTimestamp | tail -n 30


```





---





## Next module





[2.4 Workloads](../04-workloads/README.md) (per suggested course order), or open [2.3 Containers](../03-containers/README.md) if you prefer runtime-first.


