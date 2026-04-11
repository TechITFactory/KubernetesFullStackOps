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

If this feels overwhelming — do the first steps and come back later.

## One-time setup

```bash
COURSE_DIR="$HOME/K8sOps"
cd "$COURSE_DIR/00-Prerequisites/01-linux-basics-for-kubernetes"
```

> If you set `COURSE_DIR` in an earlier lesson this session, it is still set — skip the export and just `cd`.

> **WSL2 users:** keep `COURSE_DIR` under a Linux path (e.g. `~/K8sOps`), not under `/mnt/c/`. Permissions and I/O are much faster inside the Linux filesystem.

## Flow of this lesson

```
  [ Step 1 ]           [ Step 2 ]           [ Steps 3–7 ]        [ Step 8 ]
  Move into      →     Set up lab      →     ls / grep /    →     verify-
  lesson folder        workspace             find / ps            linux-basics.sh
```

**Say:**

We move through four stages. First we land in the lesson folder so paths like `scripts/` work. Then we copy lab files into a folder under your home directory. Next we practice listing, grepping, finding, and quick process checks inside that lab copy. Last we return to the repo and run the verify script.

---

## Step 1 — Move into the lesson folder

**What happens when you run this:**

`cd` changes your shell’s working directory to the lesson folder (paths like `scripts/` resolve from there). `pwd` prints the full path — no files are created or changed.

**Say:**

I move into the lesson directory so `scripts/` paths work. `pwd` shows my location.

**Run:**

```bash
cd "$COURSE_DIR/00-Prerequisites/01-linux-basics-for-kubernetes"
pwd
```

**Expected:**

Path ending with `01-linux-basics-for-kubernetes`.

---

## Step 2 — Set up the lab workspace

**What happens when you run this:**

`chmod +x scripts/*.sh` marks every script in `scripts/` as executable (so `./script.sh` works). `./scripts/setup-linux-lab-workspace.sh` creates `~/k8sops-p0-linux-lab` (or `K8SOPS_P0_LINUX_LAB`) and **copies** the contents of `lab-files/` into it — your repo is unchanged; the lab is a disposable copy.

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

**What happens when you run this:**

`cd` goes to the lab workspace. `pwd` confirms location. `ls -la` lists all files (including hidden) with details — read-only; nothing is modified.

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

**What happens when you run this:**

`grep` reads `servers.log` and prints only lines containing a space, the word `ERROR`, and another space — stdout only; the file is not changed. The spaces stop false matches like `ERRORCODE`.

**Say:**

`grep` keeps lines that match. I use double quotes around the pattern so the spaces around `ERROR` match the verify script exactly.

**Run:**

```bash
grep " ERROR " servers.log
```

**Expected:**

Two lines containing ` ERROR `.

---

## Step 5 — Count matches

**What happens when you run this:**

`grep` outputs matching lines; `|` pipes that stream into `wc -l`, which counts newline-terminated lines and prints one number — still read-only on disk.

**Say:**

The pipe sends the left command’s output into the right command. Here I count how many lines matched.

**Run:**

```bash
grep " ERROR " servers.log | wc -l
```

**Expected:**

A small number (e.g. `2`).

---

## Step 6 — Read specific parts

**What happens when you run this:**

`grep '^APP_' config.env` prints lines in `config.env` that **start with** `APP_`. `head -n 2 servers.log` prints the first two lines of the log; `tail -n 2 servers.log` prints the last two — all read-only.

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

**What happens when you run this:**

`find . -type f -name '*.txt'` walks the current directory tree and prints paths of `.txt` files. `ps aux | head -n 5` shows a snapshot of running processes (first five lines). The `ss` / `netstat` line tries listening TCP sockets — read-only introspection; `|| true` at the end means if every tool in the chain is missing or fails, the shell still returns success so a script or pasted block does not stop.

**Say:**

`find` locates files when you forgot the path. `ps` lists processes; `ss` (or `netstat`) shows listening ports — quick health checks. I append `|| true` so a missing `ss` and `netstat` does not make the whole line fail.

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

**What happens when you run this:**

`./scripts/verify-linux-basics.sh` `cd`s into the lab folder, counts ` ERROR ` lines and total lines in `servers.log`, checks `nested/data.txt` exists, then prints `verify-linux-basics: OK` or exits with an error — it does **not** modify your files.

**Say:**

We were editing and listing files inside the lab copy at `~/k8sops-p0-linux-lab`. The verify script lives next to `scripts/` in the repo, so I `cd` back to the lesson folder first. That way the next lesson’s paths that start from the repo also work.

**Run:**

```bash
cd "$COURSE_DIR/00-Prerequisites/01-linux-basics-for-kubernetes"
./scripts/verify-linux-basics.sh
```

**Expected:**

`verify-linux-basics: OK`.

---

## Troubleshooting

- **`Permission denied` when running `./scripts/...`** → `chmod +x scripts/*.sh`
- **`grep` prints nothing in steps 4–5** → `pwd` must be `~/k8sops-p0-linux-lab` (or your `K8SOPS_P0_LINUX_LAB`); run Step 3’s `cd` into the lab first
- **`verify-linux-basics` fails on ERROR count** → open `~/k8sops-p0-linux-lab/servers.log` and confirm at least one line contains a space, `ERROR`, and a space; use `grep " ERROR "` to match the script
- **`Lab workspace missing` from verify** → run `./scripts/setup-linux-lab-workspace.sh` from the lesson folder (Step 2)
- **`ss: command not found` and noisy `netstat`** → expected on minimal images; the `|| true` line still completes; install `iproute2` if you want `ss`
- **WSL labs under `/mnt/c/` feel slow or permission errors** → clone or copy the course under `~/` inside Linux

---

## Learning objective

- Used `cd`, `pwd`, and `ls` to orient in the shell and lab folder.
- Filtered log lines with `grep " ERROR "` and counted matches with a pipe to `wc -l`.
- Practiced `find`, `head`/`tail`, and a quick listening-port check without breaking the session when a tool was missing.

## Why this matters

In real DevOps you debug in the terminal, read logs, and filter for the signal. Comfort here means calmer work during incidents and faster Kubernetes labs later.

## Video close — fast validation

**What happens when you run this:**

These commands only read state: they confirm the lab folder and one grep count. They do not change files.

**Say:**

I quickly confirm the lab still exists and that the log still has error lines before I wrap the segment.

**Run:**

```bash
test -f "${K8SOPS_P0_LINUX_LAB:-$HOME/k8sops-p0-linux-lab}/servers.log" && echo "servers.log OK"
grep -c " ERROR " "${K8SOPS_P0_LINUX_LAB:-$HOME/k8sops-p0-linux-lab}/servers.log" 2>/dev/null || true
```

**Expected:**

`servers.log OK` and a positive integer for the error line count.

---

## Repo files (reference)

| Path | Purpose |
|------|---------|
| `lab-files/` | Source files copied into `~/k8sops-p0-linux-lab` by setup |
| `scripts/setup-linux-lab-workspace.sh` | Creates the lab folder |
| `scripts/verify-linux-basics.sh` | Step 8 check |
| `yamls/failure-troubleshooting.yaml` | Optional cheat sheet (same idea as K8s lesson YAMLs) |

---

## Challenge

**What happens when you run this:**

You edit the **lab copy** at `~/k8sops-p0-linux-lab/servers.log` (not the file inside the repo), add a line that includes ` ERROR `, then re-run the verify script.

**Say:**

The challenge file lives only under your home directory in the lab folder we created. I add one realistic log line with spaces around `ERROR`, save, then run verify from the lesson folder again.

**Run:**

Open `~/k8sops-p0-linux-lab/servers.log` in any editor and add a line like:

```
2025-04-01T10:00:06Z ERROR simulated crash on node worker-2
```

Then:

```bash
cd "$COURSE_DIR/00-Prerequisites/01-linux-basics-for-kubernetes"
./scripts/verify-linux-basics.sh
```

**Expected:**

`verify-linux-basics: OK` with an increased `ERROR lines=` count in the message.

---

## Next

[0.2 Docker basics for Kubernetes](../02-docker-basics-for-kubernetes/README.md)
