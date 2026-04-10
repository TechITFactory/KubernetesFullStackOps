# 0.1 Linux Basics for Kubernetes — teaching transcript

## Intro

Alright — in this lesson, we’re not learning full Linux.

We’re only focusing on the exact shell skills you’ll use in Kubernetes labs and real DevOps work:

- Navigating folders
- Reading logs
- Filtering output
- Doing quick system checks

That’s it.

If you’re completely new to terminal — don’t worry.
You just need to:

- Open terminal
- Paste commands
- Press Enter

If you’re on Windows, use WSL2 with Ubuntu.

Replace **`/path/to/K8sOps`** in the steps below with the folder where you cloned this repo.

If this feels overwhelming — do the first steps and come back later.

---

## Step 1 — Move into the lesson folder

**Say:**  
I move into the lesson directory so `scripts/` paths work. `pwd` shows my location.

**Run:**

```bash
cd /path/to/K8sOps/part-0-prerequisites/0.1-linux-basics-for-kubernetes
pwd
```

**Expected:**  
Path ending with `0.1-linux-basics-for-kubernetes`.

---

## Step 2 — Set up the lab workspace

**Say:**  
Scripts need execute permission. Setup copies sample files into a folder under my home directory — safe to delete later.

**Run:**

```bash
chmod +x scripts/*.sh
./scripts/setup-linux-lab-workspace.sh
```

**Expected:**  
`Lab workspace ready at: .../k8sops-p0-linux-lab`  
(Optional: set `K8SOPS_P0_LINUX_LAB` before setup if you want a different path.)

---

## Step 3 — Explore files

**Say:**  
I work inside the lab folder. `ls` is a bit like `kubectl get` — what exists *here*?

**Run:**

```bash
cd "${K8SOPS_P0_LINUX_LAB:-$HOME/k8sops-p0-linux-lab}"
pwd
ls -la
```

**Expected:**  
`servers.log`, `config.env`, and `nested/`.

---

## Step 4 — Read logs

**Say:**  
`grep` keeps lines that match — same habit you’ll use with long `kubectl logs` output.

**Run:**

```bash
grep 'ERROR' servers.log
```

**Expected:**  
Two lines containing `ERROR`.

---

## Step 5 — Count matches

**Say:**  
The pipe `|` sends the left command’s output into the right command. Here I count how many lines matched.

**Run:**

```bash
grep 'ERROR' servers.log | wc -l
```

**Expected:**  
A small number (e.g. `2`).

---

## Step 6 — Read specific parts

**Say:**  
`^APP_` in a pattern means lines that *start with* `APP_`. `head` / `tail` show the start or end of a file.

**Run:**

```bash
grep '^APP_' config.env
head -n 2 servers.log
tail -n 2 servers.log
```

**Expected:**  
Lines starting with `APP_`, plus first two and last two log lines.

---

## Step 7 — Find and quick system check

**Say:**  
`find` locates files when you forgot the path. `ps` lists processes; `ss` (or `netstat`) shows listening ports — quick health checks.

**Run:**

```bash
find . -type f -name '*.txt'
ps aux | head -n 5
command -v ss >/dev/null && ss -tlnp | head -n 10 || netstat -tlnp 2>/dev/null | head -n 10 || true
```

**Expected:**  
At least `./nested/data.txt` from `find`; other output varies by machine.

---

## Step 8 — Verify

**Say:**  
The course script checks that the workspace and grep results match what we expect.

**Run:**

```bash
cd /path/to/K8sOps/part-0-prerequisites/0.1-linux-basics-for-kubernetes
./scripts/verify-linux-basics.sh
```

**Expected:**  
`verify-linux-basics: OK`.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `lab-files/` | Source files copied into `~/k8sops-p0-linux-lab` by setup |
| `scripts/setup-linux-lab-workspace.sh` | Creates the lab folder |
| `scripts/verify-linux-basics.sh` | Step 8 check |
| `yamls/failure-troubleshooting.yaml` | Optional cheat sheet (same idea as K8s lesson YAMLs) |

---

## Troubleshooting

- Wrong folder → `pwd` and `ls`
- Permission denied → `chmod +x scripts/*.sh`
- `grep` empty → you must be in `~/k8sops-p0-linux-lab` for steps 4–7
- `ss` missing → use `netstat` if present, or skip
- WSL → keep labs under `~/` in Linux, not only under `/mnt/c/`

---

## Learning objective

- `cd`, `pwd`, `ls`
- `grep` and pipes
- Basic troubleshooting

---

## Why this matters

In real DevOps:

- You debug in the terminal
- You read logs
- You filter for the signal

Speed here = calmer incidents later.

---

## Challenge

Add another line containing `ERROR` to `servers.log`, then run:

```bash
cd /path/to/K8sOps/part-0-prerequisites/0.1-linux-basics-for-kubernetes
./scripts/verify-linux-basics.sh
```

---

## Next

[0.2 Docker basics for Kubernetes](../0.2-docker-basics-for-kubernetes/README.md)
