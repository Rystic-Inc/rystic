# Installing the Rystic MCP server

These steps set up the Rystic MCP server for an AI agent such as Cline.
`rystic mcp` is a local MCP server that lets your coding agent run Rystic
simulators of real APIs (Stripe, GitHub, Slack and more) on your machine. It
ships inside the `rystic` CLI and speaks MCP over stdio. Do each step in order and stop to tell the user if one fails.

## 1. Install the rystic CLI

Check whether it is already installed:

```sh
rystic version
```

If that fails with "command not found", install it (Mac or Linux, 64-bit).
`RYSTIC_NO_LOGIN=1` stops the installer from starting an interactive sign-in;
step 2 signs in instead:

```sh
curl -fsSL https://www.rystic.ai/install.sh | RYSTIC_NO_LOGIN=1 sh
```

The installer prints the path it installed to, such as `/usr/local/bin/rystic`
or `~/.local/bin/rystic`. If it notes that the directory is not on `PATH`, use
that full path wherever these steps say `rystic`, including the `command` in
step 3. Run `rystic version` again (or the full path) to confirm.

Then check that this CLI has the MCP server:

```sh
rystic help mcp
```

If it reports an unknown command, run `rystic self-update` and check again.

## 2. Sign in

The user must sign in once before simulators can be downloaded. First check
whether they already have:

```sh
rystic status --offline
```

If it shows a `license:` line marked `EXPIRED`, signing in does not replace
that license: tell the user it has expired and stop. If it prints
`credential: none`, start the sign-in in the background, because it waits up
to 15 minutes for the user to approve it. Its log goes in a new private
directory:

```sh
dir="$(mktemp -d)"; echo "$dir"
rystic login --no-browser < /dev/null > "$dir/login.log" 2>&1 &
```

Note the directory it prints. After a few seconds, read `login.log` there. Its
first lines are
`to sign in, open: <link>` and the code to confirm. Show the user both, and ask
them to open the link, check that the page shows the same code, and sign in or
create a free account. Then read the log every few seconds:

- a line starting `rystic:`, at any point, means the sign-in failed or timed
  out. Show that line to the user and stop; run the sign-in again only if
  they ask.
- otherwise, a line starting `approved` means the user signed in; the line
  starting `next:`, which the command prints last, means it has finished.

Either way, remove that directory once the command has finished.

If the user gives you an API key instead (it starts with `rys_`), pass it on
stdin rather than as an argument, so it stays out of `rystic`'s arguments and
the process list:

```sh
printf '%s' "$RYSTIC_KEY" | rystic login --token-stdin; unset RYSTIC_KEY
```

with the key in the `RYSTIC_KEY` environment variable. Better still, ask the
user to run `rystic login --token-stdin` themselves and paste the key there,
so it never passes through your terminal.

## 3. Add the server to Cline

Add this entry to the `mcpServers` object in Cline's MCP settings file
(`cline_mcp_settings.json`), keeping any servers already there:

```json
{
  "mcpServers": {
    "rystic": {
      "command": "rystic",
      "args": ["mcp"],
      "disabled": false,
      "autoApprove": []
    }
  }
}
```

If `rystic` is not on `PATH`, set `command` to the full path from step 1.
No environment variables or keys go in this file: the CLI reads the sign-in
from step 2.

## 4. Verify

Print the server's description and tool list:

```sh
rystic help mcp
```

Then confirm that Cline shows the `rystic` server as connected, with tools
including `list_twins`, `start_twin`, `seed`, `reset`, `inspect_state` and
`list_calls`. Call `list_twins`: with nothing started yet, it answers with an
empty list. To try a simulator, call `start_twin` with a product name that
`rystic list` prints, such as `stripe-twin`.

## Troubleshooting

- `rystic help mcp` reports an unknown command: run `rystic self-update`.
- `start_twin` reports that you are not signed in or your plan does not cover
  the product: repeat step 2, or run `rystic list` to see the products your
  plan covers.
- Full guide: https://www.rystic.ai/docs/mcp-server
- Anything else: email help@rystic.ai.
