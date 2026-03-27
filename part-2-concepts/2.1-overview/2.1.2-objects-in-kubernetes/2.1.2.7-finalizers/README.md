# 2.1.2.7 Finalizers

- Summary: Finalizers delay object deletion until cleanup steps complete, which is powerful but also a common source of “stuck” resources.
- Content: This subsection shows a simple finalizer example and explains why force-removing finalizers should be deliberate.
- Lab: Create the sample object, mark it for deletion, and observe finalizer behavior.

## Assets

- `yamls/finalizer-demo.yaml`
