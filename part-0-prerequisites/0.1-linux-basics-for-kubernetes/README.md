# 0.1 Linux Basics for Kubernetes

- **Summary**: Command-line and OS fundamentals you use in every Kubernetes lab — paths, pipes, text tools, processes, and simple networking checks.
- **Content**: Not a full Linux admin track; only what this course assumes before Part 1.
- **Lab**: Create a practice workspace from repo files, run grep/pipe exercises, then self-check with the verify script (Linux host or **WSL2**).

**Want it like a real class?** Start with **[Teach-as-you-go script](#teach-as-you-go-script-say-this-then-run-this)** below — talk and commands are woven together. Everything after that is the same lesson in “reference” layout (Lab, Quick Start, compact Transcript).

## If you have zero prior experience

- **Honest bar**: This lesson assumes you can open a terminal and type (or paste) a line and press Enter. It does **not** assume Linux, Docker, or Kubernetes.
- If the terminal itself is new: spend a short time learning “open terminal, current folder, run a command” (for Windows, **WSL2 + Ubuntu** matches the rest of this course). Then return here.
- **Pace**: On the first day, only do **Lab Step 1** and **Step 2**. Come back for Step 3–4 when comfortable.

## Teach-as-you-go script (say this, then run this)

Use this top-to-bottom for **recording** or **self-study**: read **You say** out loud (or in your head), then run **You run**. Replace `/path/to/K8sOps` with your real clone path.

---

**You say:** “We are not learning Linux for its own sake. Kubernetes engineers live in a shell: logs, paths, and filters. Today we only practice those three ideas.”

**You run:** (open a terminal — nothing to paste yet)

---

**You say:** “First I need to stand inside the lesson folder so paths like `scripts/` work. `pwd` later will prove where I am.”

**You run:**

```bash
cd /path/to/K8sOps/part-0-prerequisites/0.1-linux-basics-for-kubernetes
pwd
```

**You should see:** A path ending in `0.1-linux-basics-for-kubernetes`.

---

**You say:** “Scripts must be executable. Then the setup script copies fake lab files into my home directory so we never touch system files.”

**You run:**

```bash
chmod +x scripts/*.sh
./scripts/setup-linux-lab-workspace.sh
```

**You should see:** `Lab workspace ready at: .../k8sops-p0-linux-lab` (or the path in `$K8SOPS_P0_LINUX_LAB` if you set it).

---

**You say:** “Now I `cd` into that lab folder. `ls` lists files; this is the same mental model as `kubectl get` — I am listing what exists in *this* place.”

**You run:**

```bash
cd "${K8SOPS_P0_LINUX_LAB:-$HOME/k8sops-p0-linux-lab}"
pwd
ls -la
```

**You should see:** `servers.log`, `config.env`, and `nested/`.

---

**You say:** “`grep` keeps only lines that match. On a cluster you will grep `kubectl logs` output the same way.”

**You run:**

```bash
grep 'ERROR' servers.log
```

**You should see:** Two lines containing `ERROR`.

---

**You say:** “The pipe `|` sends the left command’s output into the right command. Here I count how many lines matched.”

**You run:**

```bash
grep 'ERROR' servers.log | wc -l
```

**You should see:** `2` (or another small number).

---

**You say:** “`^APP_` means ‘lines that start with APP_.’ Config files and env snippets show up in real incidents.”

**You run:**

```bash
grep '^APP_' config.env
head -n 2 servers.log
tail -n 2 servers.log
```

**You should see:** Lines starting with `APP_`; first two and last two log lines.

---

**You say:** “`find` walks the tree — useful when you do not remember where a file landed. `ps` and `ss` are quick health checks; skip if a command is missing on your OS.”

**You run:**

```bash
find . -type f -name '*.txt'
ps aux | head -n 5
command -v ss >/dev/null && ss -tlnp | head -n 10 || netstat -tlnp 2>/dev/null | head -n 10 || true
```

**You should see:** At least `nested/data.txt` from `find`; process and port output may vary.

---

**You say:** “Finally I run the course check script. If it prints OK, my workspace and grep results match what the lesson expects.”

**You run:**

```bash
cd /path/to/K8sOps/part-0-prerequisites/0.1-linux-basics-for-kubernetes
./scripts/verify-linux-basics.sh
```

**You should see:** `verify-linux-basics: OK (...)`.

---

**You say:** “If anything failed, I run `pwd` and `ls` — wrong directory is the most common beginner bug. Next lesson we plug this shell into Docker, then Part 1 plugs Docker into Kubernetes.”

---

## How commands and transcript fit together (not two different lessons)

The **Teach-as-you-go script** above is the **merged** format: talk + commands in one linear flow. Use it when you want to sound like a single continuous lesson.

Everything below splits the **same** content for reference:

- **Lab** / **Quick Start** = command blocks only (easy copy-paste).
- **Transcript** at the bottom = **compact** spoken recap without repeating every command block.

Typical use:

| Mode | What you do |
|------|----------------|
| **Self-study** | Prefer **Teach-as-you-go script** once (say → run → check), then read **Concepts**; use **Lab** / **Quick Start** as a cheat sheet; optional **Transcript** recap. |
| **Teaching / recording** | Prefer **Teach-as-you-go script** (say → run → check). Or: **Lab** block on screen + **Transcript** segment from the mapping table. |
| **Fast review** | Use **Quick Start** + **Video close** only. |

**Transcript ↔ lab mapping (0.1)**

| Transcript | Follow on screen / keyboard |
|------------|-----------------------------|
| `[0:00-0:30]` Hook | Intro only; optionally show **Summary** + **Learning Objective**. |
| `[0:30-2:00]` Concept | **Concepts (Short Theory)** bullets; no new commands required. |
| `[2:00-7:00]` Hands-on | **Lab Steps 1–4** (setup → grep/pipes → find/ps/ss → verify). |
| `[7:00-9:00]` Troubleshooting | **Troubleshooting (Top 5)** + optional **Failure Troubleshooting Asset** file. |
| `[9:00-10:00]` Recap | **Summary**, **Next Lesson**, run **Video close** commands. |

**What is *not* inside this README**

| Location | What lives there |
|----------|------------------|
| `lab-files/` | Sample log/config files the setup script copies into your home directory. |
| `scripts/*.sh` | Setup and automated check (you still learn the raw commands in the Lab first). |
| `yamls/failure-troubleshooting.yaml` | Optional cheat sheet in the same shape as Kubernetes lessons (`kubectl apply` only if you want it in a cluster). |

## Metadata

- Duration: `90–120` minutes (first pass)
- Difficulty: `Beginner`
- Practical/Theory: `70/30`
- Tested on Kubernetes: `N/A` (host skills)
- Also valid for: `Any Linux-like environment used for kubectl labs (incl. WSL2 Ubuntu)`
- Lab OS: `Linux` or `WSL2 (Ubuntu-style)`
- Platform: `Local shell`

## Learning Objective

By the end of this lesson, you will be able to:

- Navigate the filesystem with absolute and relative paths and explain where you are (`pwd`).
- Use pipes, redirection, and `grep` to filter logs and config snippets like you will with `kubectl logs` output.
- Locate listening ports and running processes at a basic level (`ss` / `ps`).
- Read `--help` / `man` to recover when a flag is wrong.

## Why This Matters in Real Jobs

Kubernetes troubleshooting is mostly **SSH or bastion → shell → kubectl → logs and YAML**. If the shell feels foreign, every incident takes longer and mistakes (wrong file, wrong directory, destructive `rm`) happen under pressure. Teams expect you to combine `grep`, `find`, and `curl` without thinking.

## Prerequisites

- A terminal (bare Linux, macOS with bash/zsh, or **WSL2** on Windows).
- No prior Kubernetes knowledge.

## Concepts (Short Theory)

- **Current working directory**: Commands resolve relative paths from where you `cd`; `pwd` removes guesswork.
- **Stdout vs stderr**: Many tools print errors on stderr; `2>&1` merges streams when you need one pipe.
- **Exit codes**: `0` success, non-zero failure; `set -e` in scripts stops on first failure (same pattern as course bash scripts).
- **Processes and ports**: A “listening” program has an address:port; conflicts show up in `kubectl` as connection errors too.

## Files

| Path | Purpose |
|------|---------|
| `lab-files/` | Sample log and config files copied into your home lab directory |
| `scripts/setup-linux-lab-workspace.sh` | Copies `lab-files/` → `~/k8sops-p0-linux-lab` (override with `K8SOPS_P0_LINUX_LAB`) |
| `scripts/verify-linux-basics.sh` | Checks grep count, line count, and nested path after setup |
| `yamls/failure-troubleshooting.yaml` | Optional: same asset shape as K8s lessons (ConfigMap cheat sheet) |

## Lab: Step-by-Step Practical

### Step 1 — Workspace

```bash
cd /path/to/K8sOps/part-0-prerequisites/0.1-linux-basics-for-kubernetes
chmod +x scripts/*.sh
./scripts/setup-linux-lab-workspace.sh
cd "${K8SOPS_P0_LINUX_LAB:-$HOME/k8sops-p0-linux-lab}"
pwd
ls -la
```

You now have `servers.log`, `config.env`, and `nested/data.txt` in a directory you can safely edit.

### Step 2 — Text and pipes

```bash
grep 'ERROR' servers.log
grep 'ERROR' servers.log | wc -l
grep '^APP_' config.env
head -n 2 servers.log
tail -n 2 servers.log
```

**Success signal**: you see two `ERROR` lines from the sample log. **Failure signal**: `grep` prints nothing (wrong pattern or wrong directory).

### Step 3 — Find, process, ports (pick what exists on your OS)

```bash
find . -type f -name '*.txt'
ps aux | head -n 5
command -v ss >/dev/null && ss -tlnp | head -n 10 || netstat -tlnp 2>/dev/null | head -n 10 || true
```

### Step 4 — Verify

```bash
cd /path/to/repo/part-0-prerequisites/0.1-linux-basics-for-kubernetes
./scripts/verify-linux-basics.sh
```

## Quick Start

```bash
chmod +x scripts/*.sh
./scripts/setup-linux-lab-workspace.sh
cd "${K8SOPS_P0_LINUX_LAB:-$HOME/k8sops-p0-linux-lab}" && grep 'ERROR' servers.log
./scripts/verify-linux-basics.sh
```

## Expected output

- `setup-linux-lab-workspace.sh` prints `Lab workspace ready at: .../k8sops-p0-linux-lab`.
- `grep 'ERROR' servers.log` shows two lines containing `ERROR`.
- `verify-linux-basics.sh` ends with `verify-linux-basics: OK`.

## Video close — fast validation

From this lesson directory:

```bash
./scripts/verify-linux-basics.sh
grep 'ERROR' "${K8SOPS_P0_LINUX_LAB:-$HOME/k8sops-p0-linux-lab}/servers.log" | wc -l
```

## Failure Troubleshooting Asset

- `yamls/failure-troubleshooting.yaml` — host permission, PATH, WSL path, and `grep` mistakes (same pattern as Kubernetes lesson assets). Optional: `kubectl apply -f yamls/failure-troubleshooting.yaml` if you already have a cluster and want the map in `default`.

## Troubleshooting (Top 5)

1. **`cp: cannot stat 'lab-files/...'`** → Run `setup-linux-lab-workspace.sh` from `0.1-linux-basics-for-kubernetes` (parent of `scripts/`).
2. **`Permission denied` on `./scripts/...`** → `chmod +x scripts/*.sh`.
3. **`grep` finds nothing** → `pwd` and `ls`; ensure you are inside the lab workspace directory.
4. **`ss: command not found`** → Use `netstat` or skip; minimal installs may omit `iproute2`.
5. **WSL path confusion** → Keep the lab under `$HOME` in Linux, not under `/mnt/c/...`, for fewer permission surprises.

## Hands-On Challenge

- Add a new line to `servers.log` with `ERROR` and re-run `verify-linux-basics.sh`. Then remove one `ERROR` line and confirm the script still passes (it only requires **at least** one ` ERROR ` line — adjust the script if you want stricter practice).

## Assessment

- Quiz: What does `2>&1` do? When is a relative path risky?
- Quiz: Why does `kubectl` output pair well with `grep` and `jq` later?
- Practical check: `./scripts/verify-linux-basics.sh` exits `0`.

## Version and Compatibility Notes

- **Distros**: Commands target common GNU/Linux and WSL2; BSD/macOS may differ slightly for `find`/`grep` edge cases.
- **shell**: Examples use `bash`; avoid `sh` if a script uses `[[`.

## Summary

- **Pattern**: `cd` → confirm with `pwd` → filter with `grep` / `|` → validate with a script.
- **Rule**: Read errors literally; rerun one command at a time under pressure.
- **Habit**: Keep course lab files under a dedicated directory you can delete and recreate.

## Next Lesson

[0.2 Docker basics for Kubernetes](../0.2-docker-basics-for-kubernetes/README.md) — uses the same shell skills to run containers locally before Part 1.

## Transcript (Simple Spoken English)

**What this section is for:** A **short, timed outline** of what you say in a ~10 minute voiceover — useful for **chapter markers** on a video or a **quick audio recap** without re-reading the full **Teach-as-you-go** script. It does **not** repeat every command; use **Teach-as-you-go** or **Lab** for the actual lines to type.

`[0:00-0:30]`  
You are not learning Linux for its own sake. You are learning the smallest slice of Linux that Kubernetes engineers use every week: move in the filesystem, read logs, and pipe output into filters.

`[0:30-2:00]`  
Think of the shell like the cockpit of a plane. Kubernetes is the autopilot later, but you still need to read gauges. `pwd` is “where am I on the disk?” `grep` is “show me only the scary lines.” That is exactly what you do when a pod crashes and you have a wall of log text.

`[2:00-7:00]`  
Run the setup script. It copies fake log files into a folder under your home directory. `cd` there. Run `grep ERROR` on `servers.log`. Count lines with a pipe into `wc`. If you see two error lines, you are doing what a junior engineer does on a support bridge — just without real customer traffic yet.

`[7:00-9:00]`  
If `grep` shows nothing, you are almost always in the wrong directory or your pattern is too strict. Run `pwd` and `ls`. If scripts say “permission denied,” mark them executable. On Windows, use WSL2 and keep files under the Linux home, not the `C:` mount, when things behave oddly.

`[9:00-10:00]`  
Run `verify-linux-basics.sh`. If it prints OK, go to Docker basics next — that is where we connect “files on disk” to “processes in containers,” which is the mental model Kubernetes inherits.
