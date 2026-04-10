# 2.4.5.2 Vertical Pod Autoscaling

- Summary: VPA adjusts pod resource requests and is best understood as a recommendation and right-sizing system with rollout implications.
- Content: Focus on recommender/updater/admission pieces and the tradeoffs with HPA.
- Lab: Review the VPA example and decide whether it should run in recommendation-only or auto mode.

## Assets

- `yamls/vpa-demo.yaml`
- `yamls/failure-troubleshooting.yaml`

## Quick Start

```bash
kubectl apply -f ../../2.4.4-managing-workloads/yamls/manage-workloads-demo.yaml
kubectl apply -f yamls/vpa-demo.yaml
kubectl get verticalpodautoscaler.autoscaling.k8s.io vpa-demo
```

## Expected output

- **Requires VPA CRDs/controller installed** in the cluster. If CRDs are missing, install the VPA components for your environment first, then re-apply.

## Video close - fast validation

```bash
kubectl api-resources | grep -i verticalpodautoscaler || true
kubectl describe vpa vpa-demo 2>/dev/null || true
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` - common missing CRD, admission webhook, and recommendation loop failures.
