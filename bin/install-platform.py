#!/usr/bin/env python3
"""
Install this repo's MCP servers + agent instructions into non-Claude AI coding
platforms. Called by install.sh, but usable standalone:

    python3 bin/install-platform.py opencode
    python3 bin/install-platform.py codex gemini
    DRY_RUN=1 python3 bin/install-platform.py opencode   # preview only

Secrets are NEVER written into the generated config files. context7 is wired to read
CONTEXT7_API_KEY from the shell environment (opencode {env:VAR}, Gemini ${VAR}, Codex
via env inheritance), so no plaintext key lands on disk. Export CONTEXT7_API_KEY in
your shell (e.g. add it to ~/.bashrc, or `set -a; source .env`).

Existing platform config files are backed up (.bak-<timestamp>) before merge, never
clobbered.
"""
import json
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
HOME = Path.home()
DRY = os.environ.get("DRY_RUN") == "1"

# ------------------------------------------------------------------ pretty print
def c(code, s): return f"\033[{code}m{s}\033[0m"
def head(s): print("\n" + c("1;35", "▶ ") + c("1", s))
def ok(s):   print("  " + c("32", "✓") + " " + s)
def warn(s): print("  " + c("33", "!") + " " + s)
def skip(s): print("  " + c("90", "·") + " " + s)

# ------------------------------------------------------------------ secrets
def load_env():
    env = {}
    f = REPO / ".env"
    if f.exists():
        for line in f.read_text().splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                env[k.strip()] = v.strip().strip('"').strip("'")
    return env

ENV = load_env()
# We do NOT bake the key into any config file. context7 reads CONTEXT7_API_KEY from
# the environment at runtime; the config only references it. This flag is just used to
# print a reminder if the key isn't available anywhere.
HAVE_KEY = bool(ENV.get("CONTEXT7_API_KEY") or os.environ.get("CONTEXT7_API_KEY"))
KEY_HINT = "export CONTEXT7_API_KEY in your shell (see .env) so context7 can authenticate"

# ------------------------------------------------------------------ backup + write
def backup(path: Path):
    if path.exists():
        b = path.with_suffix(path.suffix + f".bak-{time.strftime('%Y%m%d-%H%M%S')}")
        if not DRY:
            shutil.copy2(path, b)
        skip(f"backed up {path.name} -> {b.name}")

def read_json(path: Path):
    if path.exists():
        try:
            return json.loads(path.read_text() or "{}")
        except json.JSONDecodeError:
            warn(f"{path} is not valid JSON — starting fresh (old copy backed up)")
    return {}

def write_json(path: Path, data):
    if DRY:
        skip(f"would write {path}")
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2) + "\n")

def copy_instructions(dst: Path, src_name="AGENTS.md"):
    src = REPO / "platforms" / src_name
    if not src.exists():
        return
    backup(dst)
    if DRY:
        skip(f"would write {dst}")
    else:
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
    ok(f"instructions -> {dst}")

# ------------------------------------------------------------------ opencode
def install_opencode():
    head("opencode")
    cfg = HOME / ".config" / "opencode" / "opencode.json"
    data = read_json(cfg)
    backup(cfg)
    mcp = data.setdefault("mcp", {})
    mcp["chrome-devtools"] = {"type": "local", "command": ["chrome-devtools-mcp"], "enabled": True}
    mcp["magicui"] = {"type": "local", "command": ["npx", "-y", "@magicuidesign/mcp@latest"], "enabled": True}
    mcp["context7"] = {
        "type": "remote",
        "url": "https://mcp.context7.com/mcp",
        "enabled": True,
        # opencode interpolates {env:VAR} at load time — key stays out of the file
        "headers": {"CONTEXT7_API_KEY": "{env:CONTEXT7_API_KEY}"},
    }
    write_json(cfg, data)
    ok(f"MCP (chrome-devtools, magicui, context7) -> {cfg}")
    copy_instructions(HOME / ".config" / "opencode" / "AGENTS.md")
    if not HAVE_KEY:
        warn(KEY_HINT)

# ------------------------------------------------------------------ gemini
def install_gemini():
    head("Gemini CLI")
    cfg = HOME / ".gemini" / "settings.json"
    data = read_json(cfg)
    backup(cfg)
    mcp = data.setdefault("mcpServers", {})
    mcp["chrome-devtools"] = {"command": "chrome-devtools-mcp", "args": []}
    mcp["magicui"] = {"command": "npx", "args": ["-y", "@magicuidesign/mcp@latest"]}
    mcp["context7"] = {
        "httpUrl": "https://mcp.context7.com/mcp",
        # Gemini substitutes ${VAR} from the environment — key stays out of the file
        "headers": {"CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}"},
        "timeout": 30000,
    }
    write_json(cfg, data)
    ok(f"MCP (chrome-devtools, magicui, context7) -> {cfg}")
    copy_instructions(HOME / ".gemini" / "GEMINI.md")
    if not HAVE_KEY:
        warn(KEY_HINT)

# ------------------------------------------------------------------ codex
def _codex(*args):
    if DRY:
        skip("codex " + " ".join(args))
        return True
    try:
        subprocess.run(["codex", *args], check=False,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return True
    except FileNotFoundError:
        return False

def install_codex():
    head("Codex CLI")
    if not DRY and shutil.which("codex") is None:
        warn("codex CLI not found — skipping. Install Codex, then re-run.")
        return
    servers = [
        ("chrome-devtools", ["chrome-devtools-mcp"]),
        ("magicui", ["npx", "-y", "@magicuidesign/mcp@latest"]),
        # context7 stdio: reads CONTEXT7_API_KEY from the inherited environment,
        # so no key is written into ~/.codex/config.toml
        ("context7", ["npx", "-y", "@upstash/context7-mcp"]),
    ]
    for name, cmd in servers:
        _codex("mcp", "remove", name)          # idempotent
        if _codex("mcp", "add", name, "--", *cmd):
            ok(f"MCP: {name}")
        else:
            warn(f"MCP: {name} failed (add manually: codex mcp add {name} -- {' '.join(cmd)})")
    copy_instructions(HOME / ".codex" / "AGENTS.md")
    if not HAVE_KEY:
        warn(KEY_HINT)

# ------------------------------------------------------------------ main
INSTALLERS = {"opencode": install_opencode, "codex": install_codex, "gemini": install_gemini}

def main(argv):
    targets = argv or list(INSTALLERS)
    unknown = [t for t in targets if t not in INSTALLERS]
    if unknown:
        print(f"Unknown platform(s): {', '.join(unknown)}")
        print(f"Available: {', '.join(INSTALLERS)}")
        return 1
    if DRY:
        warn("dry-run: no changes will be made")
    for t in targets:
        INSTALLERS[t]()
    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
