#!/bin/sh
# SessionStart hook for Claude Code: when the rystic CLI, which this plugin's
# MCP server runs, is not on PATH, print how to fix it, for the user
# (systemMessage) and for Claude (additionalContext). Silent when rystic is on
# PATH. The hook command ends in `exit 0`, so a shell that cannot run this
# script (PowerShell, where Claude Code runs hooks without Git Bash) stays
# silent too.
command -v rystic >/dev/null 2>&1 && exit 0

# esc makes $1 safe inside a JSON string.
esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

found=""
for p in /usr/local/bin/rystic "${HOME:-}/.local/bin/rystic"; do
  if [ -x "$p" ]; then
    found=$p
    break
  fi
done

case $(uname -s 2>/dev/null) in
MINGW* | MSYS* | CYGWIN* | Windows_NT*) windows=1 ;;
*) windows="" ;;
esac

if [ -n "$found" ]; then
  dir=$(esc "$(dirname "$found")")
  user="Rystic: the rystic CLI is installed in $dir, but that folder is not on the PATH Claude Code started with, so the Rystic MCP server cannot start. Add $dir to your PATH (for example in your shell profile), then restart Claude Code."
  ctx="The rystic CLI is installed in $dir, but that folder is not on Claude Code's PATH, so the rystic MCP server from the Rystic plugin did not start and its tools are missing. If the user wants Rystic simulators, help them add $dir to the PATH Claude Code starts with, then restart Claude Code."
elif [ -n "$windows" ]; then
  user="Rystic: the rystic CLI is not on your PATH, so the Rystic MCP server cannot start. The installer covers macOS and Linux; for Windows, see https://www.rystic.ai/docs/installation, then restart Claude Code."
  ctx="The rystic CLI is not on PATH, so the rystic MCP server from the Rystic plugin did not start and its tools are missing. Rystic's installer covers macOS and Linux only; if the user wants Rystic simulators on Windows, point them to https://www.rystic.ai/docs/installation."
else
  user="Rystic: the rystic CLI is not installed, so the Rystic MCP server cannot start. Install it on macOS or Linux by running this in a terminal:\\n\\n  curl -fsSL https://www.rystic.ai/install.sh | sh\\n\\nthen reconnect the rystic server from /mcp. If the installer says its folder is not on your PATH, add it and restart Claude Code."
  ctx="The rystic CLI is not installed, so the rystic MCP server from the Rystic plugin did not start and its tools are missing. If the user wants Rystic simulators, offer to install it with: curl -fsSL https://www.rystic.ai/install.sh | RYSTIC_NO_LOGIN=1 sh (macOS or Linux; it prints the folder it installed to, which must be on Claude Code's PATH). Then ask the user to reconnect the rystic server from /mcp and sign in: with the server's sign_in tool if it lists one, otherwise by running rystic login in a terminal."
fi
printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$user" "$ctx"
