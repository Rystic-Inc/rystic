# Rystic MCP server

`rystic mcp` is a local MCP server that lets your coding agent run Rystic simulators of real APIs (Stripe, GitHub, Slack and more) on your machine. Through MCP tools the agent starts a simulator, loads a scenario, seeds records, moves the clock, reads state and the calls and webhooks the simulator saw, diffs state against where it started, and saves the run as a test case.

The server speaks MCP over stdio: your client launches `rystic mcp` as a subprocess. It ships inside the `rystic` CLI.

## Install

Mac or Linux, 64-bit.

```bash
curl -fsSL https://www.rystic.ai/install.sh | sh
```

The install ends by signing you in through the browser. A new account starts on the Free plan. For CI or a machine without a browser, create an API key and run `rystic login rys_…`.

Then add the server to your client:

```bash
rystic mcp install --client claude-code   # or cursor, codex, vscode, windsurf
```

Restart the client and approve the `rystic` server when it asks.

## Install as a plugin

The repository is also a plugin for each client below. Each plugin starts `rystic mcp`, so install the CLI first. When Claude Code cannot find `rystic` on its PATH, the Claude Code plugin says how to install it, or which folder to add to PATH, as a session starts or resumes.

| Client | Command |
|---|---|
| Claude Code | `claude plugin marketplace add Rystic-Inc/rystic`, then `claude plugin install rystic@rystic` |
| Codex | `codex plugin marketplace add Rystic-Inc/rystic` |
| Gemini CLI | `gemini extensions install https://github.com/Rystic-Inc/rystic` |
| Antigravity CLI | `agy plugin install https://github.com/Rystic-Inc/rystic` |

## Configure by hand

Claude Code (`.mcp.json`) and Cursor (`.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "rystic": {
      "type": "stdio",
      "command": "rystic",
      "args": ["mcp"]
    }
  }
}
```

VS Code (`.vscode/mcp.json`):

```json
{
  "servers": {
    "rystic": {
      "type": "stdio",
      "command": "rystic",
      "args": ["mcp"]
    }
  }
}
```

Codex (`.codex/config.toml`):

```toml
[mcp_servers.rystic]
command = "rystic"
args = ["mcp"]
```

If the client cannot find `rystic`, set `command` to its absolute path (`command -v rystic` prints it).

## Tools

| Tool | What it does |
|---|---|
| `list_twins` | the simulators running on this machine |
| `start_twin` | starts a simulator, optionally with a scenario, and returns its URL |
| `stop_twin` | stops a simulator |
| `list_scenarios` | the named starting worlds a simulator ships |
| `load_scenario` | wipes state and loads a scenario |
| `seed` | merges records into state |
| `set_clock` | pins the simulator's clock |
| `advance_clock` | moves the clock forward or back |
| `reset` | empties state and clears the logs |
| `inspect_state` | reads the whole state or a named view |
| `list_calls` | the API calls served since the last reset |
| `list_sent` | webhooks, emails and other outbound effects |
| `diff_state` | rows created, changed and deleted since the baseline |
| `save_test_case` | saves the run as a regression test |

The tool names say "twin", meaning a simulator.

## What leaves your machine

The plugin itself sends nothing: it starts `rystic mcp` on your machine. The `rystic` CLI calls `www.rystic.ai` to sign in, check for updates and download a simulator the first time you start it, and `registry.rystic.ai` when it runs a simulator in Docker. On the Free and Pro plans a running simulator checks in with `lease.rystic.ai` at start, every 30 seconds and on exit, carrying your API key and the windows in which it was in use, never your requests, data or hostname. Full list: https://www.rystic.ai/docs/cli#what-leaves-your-machine

## Run in a container

The [Dockerfile](Dockerfile) builds an image that runs `rystic mcp` on stdio. It
installs the Linux build of the `rystic` CLI that www.rystic.ai names for the
image's platform and checks its SHA-256 before installing it.

```bash
docker build -t rystic-mcp .
docker run -i --rm rystic-mcp
```

The image installs the newest CLI when it is built. Add
`--build-arg RYSTIC_VERSION=<version>` to pin a release, or `--no-cache` to pick
up a newer one on a rebuild.

Building pulls the Debian base image from Docker Hub, installs packages from
Debian's mirrors and downloads the CLI. Starting the server and listing its
tools need no network or sign-in. A simulator the server starts inside the
container is reachable only from inside it, and needs a signed-in CLI there, so
for everyday use install the CLI on your machine as above.

## Cline

Cline can install the server for you by following [llms-install.md](llms-install.md),
which covers installing the CLI, signing in and adding the server to Cline's MCP
settings.

## Documentation

Full reference: https://www.rystic.ai/docs/mcp-server

## License

MIT. See [LICENSE](LICENSE).
