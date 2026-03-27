from pathlib import Path
import re


ROOT = Path(r"c:\Users\USER\Desktop\Kubernetes Full Stack Ops\part-2-concepts")


TREE = {
    "2.5-services-load-balancing-and-networking": {
        "title": "2.5 Services, Load Balancing, and Networking",
        "children": {
            "2.5.1-service": "2.5.1 Service",
            "2.5.2-ingress": "2.5.2 Ingress",
            "2.5.3-ingress-controllers": "2.5.3 Ingress Controllers",
            "2.5.4-gateway-api": "2.5.4 Gateway API",
            "2.5.5-endpointslices": "2.5.5 EndpointSlices",
            "2.5.6-network-policies": "2.5.6 Network Policies",
            "2.5.7-dns-for-services-and-pods": "2.5.7 DNS for Services and Pods",
            "2.5.8-ipv4-ipv6-dual-stack": "2.5.8 IPv4/IPv6 Dual-Stack",
            "2.5.9-topology-aware-routing": "2.5.9 Topology Aware Routing",
            "2.5.10-networking-on-windows": "2.5.10 Networking on Windows",
            "2.5.11-service-clusterip-allocation": "2.5.11 Service ClusterIP Allocation",
            "2.5.12-service-internal-traffic-policy": "2.5.12 Service Internal Traffic Policy",
        },
    },
    "2.6-storage": {
        "title": "2.6 Storage",
        "children": {
            "2.6.1-volumes": "2.6.1 Volumes",
            "2.6.2-persistent-volumes": "2.6.2 Persistent Volumes",
            "2.6.3-projected-volumes": "2.6.3 Projected Volumes",
            "2.6.4-ephemeral-volumes": "2.6.4 Ephemeral Volumes",
            "2.6.5-storage-classes": "2.6.5 Storage Classes",
            "2.6.6-volume-attributes-classes": "2.6.6 Volume Attributes Classes",
            "2.6.7-dynamic-volume-provisioning": "2.6.7 Dynamic Volume Provisioning",
            "2.6.8-volume-snapshots": "2.6.8 Volume Snapshots",
            "2.6.9-volume-snapshot-classes": "2.6.9 Volume Snapshot Classes",
            "2.6.10-csi-volume-cloning": "2.6.10 CSI Volume Cloning",
            "2.6.11-storage-capacity": "2.6.11 Storage Capacity",
            "2.6.12-node-specific-volume-limits": "2.6.12 Node-specific Volume Limits",
            "2.6.13-local-ephemeral-storage": "2.6.13 Local Ephemeral Storage",
            "2.6.14-volume-health-monitoring": "2.6.14 Volume Health Monitoring",
            "2.6.15-windows-storage": "2.6.15 Windows Storage",
        },
    },
    "2.7-configuration": {
        "title": "2.7 Configuration",
        "children": {
            "2.7.1-configmaps": "2.7.1 ConfigMaps",
            "2.7.2-secrets": "2.7.2 Secrets",
            "2.7.3-liveness-readiness-and-startup-probes": "2.7.3 Liveness, Readiness, and Startup Probes",
            "2.7.4-resource-management-for-pods-and-containers": "2.7.4 Resource Management for Pods and Containers",
            "2.7.5-organizing-cluster-access-using-kubeconfig-files": "2.7.5 Organizing Cluster Access Using kubeconfig Files",
            "2.7.6-resource-management-for-windows-nodes": "2.7.6 Resource Management for Windows Nodes",
        },
    },
    "2.8-security": {
        "title": "2.8 Security",
        "children": {
            "2.8.1-cloud-native-security": "2.8.1 Cloud Native Security",
            "2.8.2-pod-security-standards": "2.8.2 Pod Security Standards",
            "2.8.3-pod-security-admission": "2.8.3 Pod Security Admission",
            "2.8.4-service-accounts": "2.8.4 Service Accounts",
            "2.8.5-pod-security-policies": "2.8.5 Pod Security Policies",
            "2.8.6-security-for-linux-nodes": "2.8.6 Security For Linux Nodes",
            "2.8.7-security-for-windows-nodes": "2.8.7 Security For Windows Nodes",
            "2.8.8-controlling-access-to-the-kubernetes-api": "2.8.8 Controlling Access to the Kubernetes API",
            "2.8.9-role-based-access-control-good-practices": "2.8.9 Role Based Access Control Good Practices",
            "2.8.10-good-practices-for-kubernetes-secrets": "2.8.10 Good Practices for Kubernetes Secrets",
            "2.8.11-multi-tenancy": "2.8.11 Multi-tenancy",
            "2.8.12-hardening-guide-authentication-mechanisms": "2.8.12 Hardening Guide - Authentication Mechanisms",
            "2.8.13-hardening-guide-scheduler-configuration": "2.8.13 Hardening Guide - Scheduler Configuration",
            "2.8.14-kubernetes-api-server-bypass-risks": "2.8.14 Kubernetes API Server Bypass Risks",
            "2.8.15-linux-kernel-security-constraints-for-pods-and-containers": "2.8.15 Linux Kernel Security Constraints for Pods and Containers",
            "2.8.16-security-checklist": "2.8.16 Security Checklist",
            "2.8.17-application-security-checklist": "2.8.17 Application Security Checklist",
        },
    },
    "2.9-policies": {
        "title": "2.9 Policies",
        "children": {
            "2.9.1-limit-ranges": "2.9.1 Limit Ranges",
            "2.9.2-resource-quotas": "2.9.2 Resource Quotas",
            "2.9.3-process-id-limits-and-reservations": "2.9.3 Process ID Limits and Reservations",
            "2.9.4-node-resource-managers": "2.9.4 Node Resource Managers",
        },
    },
    "2.10-scheduling-preemption-and-eviction": {
        "title": "2.10 Scheduling, Preemption and Eviction",
        "children": {
            "2.10.1-kubernetes-scheduler": "2.10.1 Kubernetes Scheduler",
            "2.10.2-assigning-pods-to-nodes": "2.10.2 Assigning Pods to Nodes",
            "2.10.3-pod-overhead": "2.10.3 Pod Overhead",
            "2.10.4-pod-scheduling-readiness": "2.10.4 Pod Scheduling Readiness",
            "2.10.5-pod-topology-spread-constraints": "2.10.5 Pod Topology Spread Constraints",
            "2.10.6-taints-and-tolerations": "2.10.6 Taints and Tolerations",
            "2.10.7-scheduling-framework": "2.10.7 Scheduling Framework",
            "2.10.8-dynamic-resource-allocation": "2.10.8 Dynamic Resource Allocation",
            "2.10.9-gang-scheduling": "2.10.9 Gang Scheduling",
            "2.10.10-scheduler-performance-tuning": "2.10.10 Scheduler Performance Tuning",
            "2.10.11-resource-bin-packing": "2.10.11 Resource Bin Packing",
            "2.10.12-pod-priority-and-preemption": "2.10.12 Pod Priority and Preemption",
            "2.10.13-node-pressure-eviction": "2.10.13 Node-pressure Eviction",
            "2.10.14-api-initiated-eviction": "2.10.14 API-initiated Eviction",
            "2.10.15-node-declared-features": "2.10.15 Node Declared Features",
        },
    },
    "2.11-cluster-administration": {
        "title": "2.11 Cluster Administration",
        "children": {
            "2.11.1-node-shutdowns": "2.11.1 Node Shutdowns",
            "2.11.2-swap-memory-management": "2.11.2 Swap Memory Management",
            "2.11.3-node-autoscaling": "2.11.3 Node Autoscaling",
            "2.11.4-certificates": "2.11.4 Certificates",
            "2.11.5-cluster-networking": "2.11.5 Cluster Networking",
            "2.11.6-observability": "2.11.6 Observability",
            "2.11.7-admission-webhook-good-practices": "2.11.7 Admission Webhook Good Practices",
            "2.11.8-good-practices-for-dynamic-resource-allocation-as-a-cluster-admin": "2.11.8 Good Practices for Dynamic Resource Allocation as a Cluster Admin",
            "2.11.9-logging-architecture": "2.11.9 Logging Architecture",
            "2.11.10-compatibility-version-for-kubernetes-control-plane-components": "2.11.10 Compatibility Version For Kubernetes Control Plane Components",
            "2.11.11-metrics-for-kubernetes-system-components": "2.11.11 Metrics For Kubernetes System Components",
            "2.11.12-metrics-for-kubernetes-object-states": "2.11.12 Metrics for Kubernetes Object States",
            "2.11.13-system-logs": "2.11.13 System Logs",
            "2.11.14-traces-for-kubernetes-system-components": "2.11.14 Traces For Kubernetes System Components",
            "2.11.15-proxies-in-kubernetes": "2.11.15 Proxies in Kubernetes",
            "2.11.16-api-priority-and-fairness": "2.11.16 API Priority and Fairness",
            "2.11.17-installing-addons": "2.11.17 Installing Addons",
            "2.11.18-coordinated-leader-election": "2.11.18 Coordinated Leader Election",
        },
    },
    "2.12-windows-in-kubernetes": {
        "title": "2.12 Windows in Kubernetes",
        "children": {
            "2.12.1-windows-containers-in-kubernetes": "2.12.1 Windows Containers in Kubernetes",
            "2.12.2-guide-for-running-windows-containers-in-kubernetes": "2.12.2 Guide for Running Windows Containers in Kubernetes",
        },
    },
    "2.13-extending-kubernetes": {
        "title": "2.13 Extending Kubernetes",
        "children": {
            "2.13.1-compute-storage-and-networking-extensions": {
                "title": "2.13.1 Compute, Storage, and Networking Extensions",
                "children": {
                    "2.13.1.1-network-plugins": "2.13.1.1 Network Plugins",
                    "2.13.1.2-device-plugins": "2.13.1.2 Device Plugins",
                },
            },
            "2.13.2-extending-the-kubernetes-api": {
                "title": "2.13.2 Extending the Kubernetes API",
                "children": {
                    "2.13.2.1-custom-resources": "2.13.2.1 Custom Resources",
                    "2.13.2.2-kubernetes-api-aggregation-layer": "2.13.2.2 Kubernetes API Aggregation Layer",
                },
            },
            "2.13.3-operator-pattern": "2.13.3 Operator Pattern",
        },
    },
}


SCRIPT_TOPICS = {
    "service", "ingress", "network policies", "dns for services and pods", "configmaps", "secrets",
    "liveness, readiness, and startup probes", "organizing cluster access using kubeconfig files",
    "service accounts", "controlling access to the kubernetes api", "resource quotas", "limit ranges",
    "kubernetes scheduler", "assigning pods to nodes", "taints and tolerations", "node autoscaling",
    "certificates", "observability", "logging architecture", "system logs", "installing addons",
    "network plugins", "custom resources", "operator pattern", "persistent volumes", "storage classes",
    "dynamic volume provisioning", "volume snapshots", "service internal traffic policy", "gateways api"
}


def slug_to_title(slug: str) -> str:
    return slug.split("-", 1)[1].replace("-", " ")


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def write(path: Path, content: str) -> None:
    ensure_dir(path.parent)
    path.write_text(content, encoding="utf-8")


def note_body(title: str) -> str:
    return (
        f"apiVersion: v1\nkind: ConfigMap\nmetadata:\n  name: {to_name(title)}-notes\n  namespace: kube-system\n"
        f"data:\n  notes: |\n    {title} should be taught as a practical Kubernetes concept tied to real operational decisions.\n"
    )


def script_body(title: str) -> str:
    safe = title.lower()
    lines = [
        "#!/usr/bin/env bash",
        "set -euo pipefail",
        'command -v kubectl >/dev/null 2>&1 || { echo "kubectl missing" >&2; exit 1; }',
    ]
    if "kubeconfig" in safe:
        lines += [
            "kubectl config get-contexts",
            "echo",
            "kubectl config current-context",
        ]
    elif "service" in safe and "account" not in safe:
        lines += [
            "kubectl get svc -A",
            "echo",
            "kubectl get endpointslices -A 2>$null || kubectl get endpointslices -A",
        ]
    elif "ingress" in safe:
        lines += ["kubectl get ingress -A", 'kubectl get pods -A | grep -i ingress || true']
    elif "network" in safe:
        lines += ["kubectl get networkpolicy -A || true", "kubectl get svc -A"]
    elif "configmap" in safe:
        lines += ["kubectl get configmaps -A"]
    elif "secret" in safe:
        lines += ["kubectl get secrets -A"]
    elif "probe" in safe:
        lines += ["kubectl get pods -A -o wide"]
    elif "scheduler" in safe:
        lines += ["kubectl get pods -n kube-system | grep scheduler || true"]
    elif "taints" in safe or "assigning pods" in safe:
        lines += ["kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints"]
    elif "resource quotas" in safe or "limit ranges" in safe:
        lines += ["kubectl get resourcequota,limitrange -A"]
    elif "node autoscaling" in safe:
        lines += ["kubectl get nodes -o wide"]
    elif "certificates" in safe:
        lines += ["kubectl get csr || true"]
    elif "logging" in safe or "system logs" in safe:
        lines += ["kubectl get pods -n kube-system"]
    elif "addons" in safe:
        lines += ["kubectl get pods -n kube-system"]
    elif "custom resources" in safe:
        lines += ["kubectl api-resources | grep -i custom || true"]
    elif "operator pattern" in safe:
        lines += ["kubectl api-resources | grep -i operator || true"]
    else:
        lines += ["kubectl get ns"]
    return "\n".join(lines) + "\n"


def to_name(title: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")


def topic_summary(title: str) -> tuple[str, str, str]:
    base = title.split(" ", 1)[1] if " " in title else title
    return (
        f"{base} is a core Kubernetes concept that needs to be understood both declaratively and operationally.",
        f"This section explains {base.lower()} in practical Kubernetes terms and ties it back to observable cluster behavior.",
        f"Review the assets here, apply the sample manifest if provided, and inspect the resulting state with kubectl.",
    )


def section_readme(title: str, include_script: bool, note_file: str) -> str:
    summary, content, lab = topic_summary(title)
    assets = [f"`yamls/{note_file}`"]
    if include_script:
        assets.insert(0, f"`scripts/inspect-{to_name(title)}.sh`")
    lines = [
        f"# {title}",
        "",
        f"- Summary: {summary}",
        f"- Content: {content}",
        f"- Lab: {lab}",
        "",
        "## Assets",
        "",
    ]
    lines.extend(f"- {a}" for a in assets)
    lines.append("")
    return "\n".join(lines)


def module_readme(title: str, children_titles: list[str]) -> str:
    lines = [
        f"# {title}",
        "",
        f"- Objective: Build a practical understanding of {title.split(' ', 1)[1].lower()} in Kubernetes.",
        "- Outcomes: Explain the key concepts, inspect live cluster state, and connect the topic to real operational usage.",
        "- Notes: Use these sections as concept-plus-demo lessons rather than purely theoretical references.",
        "",
    ]
    if children_titles:
        lines += ["## Children", ""]
        lines.extend(f"- {t}" for t in children_titles)
        lines.append("")
    return "\n".join(lines)


def populate_leaf(path: Path, title: str) -> None:
    scripts_dir = path / "scripts"
    yamls_dir = path / "yamls"
    ensure_dir(scripts_dir)
    ensure_dir(yamls_dir)
    note_filename = f"{to_name(title)}-notes.yaml"
    include_script = any(k in title.lower() for k in SCRIPT_TOPICS)
    write(path / "README.md", section_readme(title, include_script, note_filename))
    write(yamls_dir / note_filename, note_body(title))
    if include_script:
        write(scripts_dir / f"inspect-{to_name(title)}.sh", script_body(title))
    else:
        write(scripts_dir / ".gitkeep", "")


def populate_node(base: Path, slug: str, node) -> str:
    path = base / slug
    if isinstance(node, str):
        populate_leaf(path, node)
        return node

    title = node["title"]
    children_titles = []
    for child_slug, child_node in node["children"].items():
        child_title = populate_node(path, child_slug, child_node)
        children_titles.append(child_title)
    write(path / "README.md", module_readme(title, children_titles))
    ensure_dir(path / "scripts")
    ensure_dir(path / "yamls")
    write(path / "scripts" / ".gitkeep", "")
    write(path / "yamls" / ".gitkeep", "")
    return title


def main() -> None:
    for top_slug, node in TREE.items():
        populate_node(ROOT, top_slug, node)
    print("Generated concept content for 2.5 through 2.13")


if __name__ == "__main__":
    main()
