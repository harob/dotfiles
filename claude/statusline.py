#!/usr/bin/python3
"""Claude Code status line.

Renders:  Sonnet 5 · ~/src/liftoff · master · Context 10% used · ~$1.97
"""
import json
import os
import subprocess
import sys

# 256-colour codes, picked to read well on a dark terminal.
ORANGE = "\033[38;5;208m"   # model
GREEN = "\033[38;5;113m"    # directory
BLUE = "\033[38;5;33m"      # git branch
RED = "\033[38;5;203m"      # context used
YELLOW = "\033[38;5;220m"   # session cost
DIM = "\033[38;5;242m"      # separators
RESET = "\033[0m"

SEP = f" {DIM}·{RESET} "


def _initial(seg):
    # Hidden directories keep their dot, so ".config" -> ".c".
    return seg[:2] if seg.startswith(".") else seg[:1]


def tilde(path):
    """Home-relative path with all but the last two directories initialled.

    /Users/me/workspace/src/studies/foo -> ~/w/s/studies/foo
    """
    home = os.path.expanduser("~")
    if path == home:
        return "~"
    if path.startswith(home + os.sep):
        root, rest = "~/", path[len(home) + 1:]
    elif os.path.isabs(path):
        root, rest = os.sep, path.lstrip(os.sep)
    else:
        root, rest = "", path

    parts = [seg for seg in rest.split(os.sep) if seg]
    if len(parts) > 2:
        parts = [_initial(seg) for seg in parts[:-2]] + parts[-2:]
    return root + os.sep.join(parts)


def git_branch(cwd):
    try:
        out = subprocess.run(
            ["git", "-C", cwd, "symbolic-ref", "--quiet", "--short", "HEAD"],
            capture_output=True, text=True, timeout=1,
        )
        if out.returncode == 0 and out.stdout.strip():
            return out.stdout.strip()
        # Detached HEAD: show the short sha instead.
        out = subprocess.run(
            ["git", "-C", cwd, "rev-parse", "--short", "HEAD"],
            capture_output=True, text=True, timeout=1,
        )
        if out.returncode == 0 and out.stdout.strip():
            return out.stdout.strip()
    except Exception:
        pass
    return None


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return

    cwd = (data.get("workspace") or {}).get("current_dir") or data.get("cwd") or os.getcwd()

    parts = []

    model = (data.get("model") or {}).get("display_name")
    if model:
        parts.append(f"{ORANGE}{model}{RESET}")

    parts.append(f"{GREEN}{tilde(cwd)}{RESET}")

    branch = git_branch(cwd)
    if branch:
        parts.append(f"{BLUE}{branch}{RESET}")

    pct = (data.get("context_window") or {}).get("used_percentage")
    if isinstance(pct, (int, float)):
        parts.append(f"{RED}Context {round(pct)}% used{RESET}")

    cost = (data.get("cost") or {}).get("total_cost_usd")
    if isinstance(cost, (int, float)):
        parts.append(f"{YELLOW}~${cost:.2f}{RESET}")

    sys.stdout.write(SEP.join(parts))


if __name__ == "__main__":
    main()
