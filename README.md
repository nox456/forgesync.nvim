# forgesync.nvim

A thin Neovim layer over the [`forgesync`](https://github.com/nox456/forgesync)
CLI. It runs your GitHub → Notion sync from inside the editor — in the
background, with notifications, a status dashboard, and optional auto-sync when
you switch projects.

The plugin **never reimplements sync logic**. Every field-ownership rule, status
mapping, and GitHub/Notion call lives in the Go CLI, where it's already tested.
forgesync.nvim shells out to the binary with `--json`, parses the result, and
either renders it or summarizes it. The Lua side stays deliberately thin.

> **Heads up:** forgesync.nvim is the front-end. The actual syncing is done by the
> `forgesync` CLI, which you must install and configure **first**. See
> [Requirements](#requirements).

---

## What it does

Three features, each mapping to one CLI command.

### Background sync with notifications

`:ForgesyncSync` runs `forgesync sync` in the background without blocking the
editor. You get a notification when it starts and a summary when it finishes
(`2 created, 1 updated`) — or the error message if it fails. A built-in guard
prevents two syncs from running at once.

### Status dashboard

`:ForgesyncDashboard` opens a floating window with a read-only table of every
issue forgesync tracks: issue number, title, project, repo, status, whether it
has a linked PR, and whether it's already in sync. Press `r` to refresh, `q` to
close. It only reads — it never writes to Notion.

### Auto-sync on project load

When you switch to a **tracked** project (one whose repo lives in your Notion
Project Manager database), forgesync.nvim can run a sync scoped to just that repo
automatically. Untracked projects are left alone. This is opt-in and needs one
small integration step — see [Auto-sync on project switch](#auto-sync-on-project-switch).

---

## Requirements

| Requirement | Why | Required? |
| ----------- | --- | --------- |
| [`forgesync` CLI](https://github.com/nox456/forgesync), installed **and configured** | Does the actual syncing | Yes |
| **Neovim ≥ 0.10** | Uses `vim.system()` for non-blocking subprocesses | Yes |
| A `vim.notify` handler (e.g. [snacks.nvim](https://github.com/folke/snacks.nvim)) | Renders the start/finish notifications | Recommended |
| [GitHub CLI](https://cli.github.com/) (`gh`), authenticated | Resolves the current repo for auto-sync | Only for auto-sync |

### Configure the CLI first

forgesync.nvim assumes `forgesync` is on your `PATH` and already set up with your
GitHub/Notion tokens and database IDs. Install it (one option):

```sh
curl -fsSL https://github.com/nox456/forgesync/releases/latest/download/install.sh | sh
```

then follow the CLI's configuration guide to create
`~/.config/forgesync/config.yaml`. Verify it works **before** installing the
plugin:

```sh
forgesync projects   # should list your Notion projects
```

If that command works in your terminal, the plugin will work too.

---

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "nox456/forgesync.nvim",
  opts = {
    -- see Configuration below; {} is fine to start
  },
}
```

`opts` is passed straight to the plugin's `setup()`. An empty table uses the
defaults.

Prefer to be explicit? This is equivalent:

```lua
{
  "nox456/forgesync.nvim",
  config = function()
    require("forgesync").setup({})
  end,
}
```

---

## Configuration

The plugin is intentionally minimal. Call `setup()` with any options you want to
override:

```lua
require("forgesync").setup({
  auto_sync = true, -- run a scoped sync when you switch to a tracked project
})
```

| Option      | Type      | Default | Description                                                                                              |
| ----------- | --------- | ------- | ------------------------------------------------------------------------------------------------------- |
| `auto_sync` | `boolean` | `true`  | Whether project-switch events trigger an automatic sync for tracked repos. Has no effect until you wire up the integration step below. |

---

## Usage

### Commands

| Command               | Action                                       |
| --------------------- | -------------------------------------------- |
| `:ForgesyncSync`      | Run a full background sync and notify the result |
| `:ForgesyncDashboard` | Open the read-only status dashboard          |

### Dashboard keys

| Key | Action               |
| --- | -------------------- |
| `r` | Refresh the table    |
| `q` | Close the window     |

### Auto-sync on project switch

Auto-sync needs to know when you've switched projects. forgesync.nvim listens for
a custom `User` autocommand — `ForgesyncProjectLoaded` — carrying the new project
path. You fire it from wherever your project picker changes directory.

With [telescope-project.nvim](https://github.com/nvim-telescope/telescope-project.nvim),
that's one extra line inside your existing `on_project_selected` hook:

```lua
on_project_selected = function(prompt_bufnr)
  project_actions.change_working_directory(prompt_bufnr)
  vim.api.nvim_exec_autocmds("User", {
    pattern = "ForgesyncProjectLoaded",
    data = { path = vim.fn.getcwd() },
  })
end,
```

When the event fires, the plugin resolves the repo (`owner/name`) with `gh`,
checks it against your tracked Notion projects, and — if it's tracked — runs
`forgesync sync --repo owner/name` in the background. Untracked projects do
nothing.

---

## How it works

```
  :ForgesyncSync
        │
        ▼
  forgesync.nvim ──vim.system──▶ forgesync (Go) ──▶ GitHub + Notion
        ▲                              │
        └────────── --json ───────────┘
        │
        ▼
  vim.notify  /  floating-window dashboard
```

Only one module ever touches JSON or spawns the binary; the rest of the plugin
works with plain Lua tables. All sync rules stay in the CLI, so the plugin can't
drift out of step with them — and changing how it talks to the CLI later is a
one-module change.

---

## Troubleshooting

| Symptom | Likely cause |
| ------- | ------------ |
| `forgesync: command not found` | The CLI isn't installed or isn't on Neovim's `PATH`. Confirm with `:!forgesync version`. |
| "Sync failed" with a config error | The CLI isn't configured. Run `forgesync projects` in a terminal to see the real error. |
| No notifications appear | No `vim.notify` handler is installed. Add snacks.nvim (or noice.nvim) for a proper notifier. |
| Auto-sync never runs | The `ForgesyncProjectLoaded` event isn't wired up, `gh` isn't authenticated, or the repo isn't tracked in Notion. |

---

## Roadmap

- [ ] Configurable `forgesync` binary path (currently assumed on `PATH`)
- [ ] Persisted tracked-projects cache between sessions
- [ ] Live-updating dashboard (currently a manual-refresh snapshot)
