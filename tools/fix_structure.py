import os, re, glob

REPO = '/c/src/K8sOps'

# ── 1. Encoding fix ──────────────────────────────────────────────────────────
def fix_encoding(raw: bytes) -> str:
    if raw.startswith(b'\xef\xbb\xbf'):
        raw = raw[3:]
    corrupted = raw.decode('utf-8')
    try:
        original_bytes = corrupted.encode('cp1252')
        return original_bytes.decode('utf-8')
    except Exception:
        return corrupted

# ── 2. Replacements ──────────────────────────────────────────────────────────
REPLACEMENTS = [
    (r'(\.\./)+part-0-prerequisites/', lambda m: m.group(0).replace('part-0-prerequisites', '00-Prerequisites')),
    (r'(\.\./)+part-1-getting-started/', lambda m: m.group(0).replace('part-1-getting-started', '01-Local-First-Operations')),
    (r'(\.\./)+part-2-concepts/', lambda m: m.group(0).replace('part-2-concepts', '02-Core-Workloads')),
    ('../2.1-overview/', '../01-overview/'),
    ('../2.2-cluster-architecture/', '../02-cluster-architecture/'),
    ('../2.3-containers/', '../03-containers/'),
    ('../2.4-workloads/', '../04-workloads/'),
    ('../2.5-services-load-balancing-and-networking/', '../05-services-load-balancing-and-networking/'),
    ('../../2.4-workloads/', '../../04-workloads/'),
    ('../../2.3-containers/', '../../03-containers/'),
    ('../../2.5-services-load-balancing-and-networking/', '../../05-services-load-balancing-and-networking/'),
    ('2.4.1-pods/2.4.1.1-pod-lifecycle',                              '02-pod-lifecycle'),
    ('2.4.1-pods/2.4.1.2-init-containers',                            '03-init-containers'),
    ('2.4.1-pods/2.4.1.3-sidecar-containers',                         '04-sidecar-containers'),
    ('2.4.1-pods/2.4.1.4-ephemeral-containers',                       '05-ephemeral-containers'),
    ('2.4.1-pods/2.4.1.5-disruptions',                                '06-disruptions'),
    ('2.4.1-pods/2.4.1.6-pod-hostname',                               '07-pod-hostname'),
    ('2.4.1-pods/2.4.1.7-pod-quality-of-service-classes',             '08-pod-quality-of-service-classes'),
    ('2.4.1-pods/2.4.1.8-workload-reference',                         '09-workload-reference'),
    ('2.4.1-pods/2.4.1.9-user-namespaces',                            '10-user-namespaces'),
    ('2.4.1-pods/2.4.1.10-downward-api',                              '11-downward-api'),
    ('2.4.1-pods/2.4.1.11-advanced-pod-configuration',                '12-advanced-pod-configuration'),
    ('2.4.2-workload-api/2.4.2.1-pod-group-policies',                 '14-pod-group-policies'),
    ('2.4.2-workload-api/',                                           '13-workload-api/'),
    ('2.4.3-workload-management/2.4.3.1-deployments',                 '16-deployments'),
    ('2.4.3-workload-management/2.4.3.2-replicaset',                  '17-replicaset'),
    ('2.4.3-workload-management/2.4.3.3-statefulsets',                '18-statefulsets'),
    ('2.4.3-workload-management/2.4.3.4-daemonset',                   '19-daemonset'),
    ('2.4.3-workload-management/2.4.3.5-jobs',                        '20-jobs'),
    ('2.4.3-workload-management/2.4.3.6-automatic-cleanup-for-finished-jobs', '21-automatic-cleanup-for-finished-jobs'),
    ('2.4.3-workload-management/2.4.3.7-cronjob',                     '22-cronjob'),
    ('2.4.3-workload-management/2.4.3.8-replicationcontroller',       '23-replicationcontroller'),
    ('2.4.3-workload-management/',                                    '15-workload-management/'),
    ('2.4.4-managing-workloads',                                      '24-managing-workloads'),
    ('2.4.5-autoscaling-workloads/2.4.5.1-horizontal-pod-autoscaling','26-horizontal-pod-autoscaling'),
    ('2.4.5-autoscaling-workloads/2.4.5.2-vertical-pod-autoscaling',  '27-vertical-pod-autoscaling'),
    ('2.4.5-autoscaling-workloads/',                                  '25-autoscaling-workloads/'),
    ('2.1.2-objects-in-kubernetes/2.1.2.1-kubernetes-object-management', '01-overview/03-kubernetes-object-management'),
    ('2.1.2-objects-in-kubernetes/2.1.2.2-object-names-and-ids',         '01-overview/04-object-names-and-ids'),
    ('2.1.2-objects-in-kubernetes/2.1.2.3-labels-and-selectors',         '01-overview/05-labels-and-selectors'),
    ('2.1.2-objects-in-kubernetes/2.1.2.4-namespaces',                   '01-overview/06-namespaces'),
    ('2.1.2-objects-in-kubernetes/2.1.2.5-annotations',                  '01-overview/07-annotations'),
    ('2.1.2-objects-in-kubernetes/2.1.2.6-field-selectors',              '01-overview/08-field-selectors'),
    ('2.1.2-objects-in-kubernetes/2.1.2.7-finalizers',                   '01-overview/09-finalizers'),
    ('2.1.2-objects-in-kubernetes/2.1.2.8-owners-and-dependents',        '01-overview/10-owners-and-dependents'),
    ('2.1.2-objects-in-kubernetes/2.1.2.9-recommended-labels',           '01-overview/11-recommended-labels'),
    ('2.1.2-objects-in-kubernetes/2.1.2.10-storage-versions',            '01-overview/12-storage-versions'),
    ('2.1.1-kubernetes-components',      '01-overview/01-kubernetes-components'),
    ('2.1.2-objects-in-kubernetes',      '01-overview/02-objects-in-kubernetes'),
    ('2.1.3-the-kubernetes-api',         '01-overview/13-the-kubernetes-api'),
    ('2.1.4-the-kubectl-command-line-tool', '01-overview/14-the-kubectl-command-line-tool'),
    ('part-2-concepts/2.4-workloads/01-pods/', '02-Core-Workloads/04-workloads/'),
    ('part-2-concepts/2.4-workloads/',         '02-Core-Workloads/04-workloads/'),
    ('part-2-concepts/',                       '02-Core-Workloads/'),
]

# ── 3. H1 heading cleanup ────────────────────────────────────────────────────
H1_PATTERN = re.compile(r'^(#\s+)\d+\.\d+(?:\.\d+)*\s+(.+)$', re.MULTILINE)

def fix_h1(text):
    return H1_PATTERN.sub(r'\1\2', text)

# ── 4. Root README Mermaid → ASCII ──────────────────────────────────────────
ROOT_MERMAID_START = '```mermaid\nflowchart TB\n  subgraph foundations'
ROOT_ASCII = '''```
  Foundations
  00: Prerequisites
       |
       v
  01: Local First Operations
       |
       v
  02: Core Workloads
       |
       +---------------------------+
       |                           |
       v                           v
  03: Packaging             05: Security & Policy
       |                           |
       v                           v
  04: CI/CD & GitOps        06: Observability
       |                           |
       +---------------------------+
                   |
                   v
         07: Capstone Project
                   |
                   v
       08: Cloud Extension (EKS)
```'''

def apply_replacements(text):
    for old, new in REPLACEMENTS:
        if callable(new):
            text = re.sub(old, new, text)
        else:
            text = text.replace(old, new)
    return text

# ── Process ──────────────────────────────────────────────────────────────────
files = glob.glob(f'{REPO}/**/*.md', recursive=True)
files = [f for f in files if '_Archived' not in f]

fixed = skipped = 0

for fpath in sorted(files):
    with open(fpath, 'rb') as fh:
        raw = fh.read()

    has_bom = raw.startswith(b'\xef\xbb\xbf')

    if has_bom:
        text = fix_encoding(raw)
    else:
        text = raw.decode('utf-8')

    original = text
    text = fix_h1(text)
    text = apply_replacements(text)

    if fpath == f'{REPO}/README.md' and ROOT_MERMAID_START in text:
        mermaid_match = re.search(r'```mermaid\nflowchart TB.*?```', text, re.DOTALL)
        if mermaid_match:
            text = text[:mermaid_match.start()] + ROOT_ASCII + text[mermaid_match.end():]

    if text != original or has_bom:
        with open(fpath, 'w', encoding='utf-8') as fh:
            fh.write(text)
        fixed += 1
    else:
        skipped += 1

print(f"Fixed: {fixed} files")
print(f"Skipped (no changes): {skipped} files")
