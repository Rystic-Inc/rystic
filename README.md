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

## Documentation

Full reference: https://www.rystic.ai/docs/mcp-server

## License

MIT. See [LICENSE](LICENSE).
