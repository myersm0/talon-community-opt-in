# talon-community-opt-in

A fork of [talonhub/community](https://github.com/talonhub/community) where **all commands are off by default**. You explicitly opt-in to the features you want via `use_*` tags.

## What This Is

The standard community repo activates all commands by default. This fork flips that: nothing is active until you enable it. Sleep/wake commands are the only exception.

This is an alternative approach, not a replacement to the official community repo. It has its own tradeoffs (see below).

## Why I Made This

Two reasons:

1. **Dedicated command palettes** — I wanted certain apps (virtual instruments, media players) to have a minimal, predictable set of commands with no chance of stray matches.

2. **Incremental learning** — You can learn Talon a little bit at a time, without being overwhelmed by the large number of commands (many of which may be irrelevant to you).

## Tradeoffs

**Benefits:**
- Smaller active vocabulary can improve recognition accuracy (especially with Conformer D2)
- You always know exactly what commands are available
- Progressive learning path for beginners
- Per-app command palettes

**Costs:**
- Another layer of abstraction to reason about when debugging
- Tag chain dependencies can be confusing (see below)
- Must manually enable features you need
- Keeping up with upstream requires re-applying guards

## Quick Start

1. Clone this repo into your Talon user directory:
   ```bash
   cd ~/.talon/user
   git clone https://github.com/myersm0/talon-community-opt-in
   ```

2. Create a personal config file (outside this repo):
   ```bash
   touch ~/.talon/user/my_config.talon
   ```

3. Add the features you want:
   ```talon
   # ~/.talon/user/my_config.talon
   -
   tag(): user.use_alphabet
   tag(): user.use_window_focus
   tag(): user.use_help
   ```

4. Restart Talon. Only those three features will be active.

## How It Works

Every `.talon` file with commands has been gated with a `use_*` tag:

```talon
# Original file (always active in command mode)
focus <user.running_applications>: user.switcher_focus(running_applications)

# This fork (requires opt-in)
tag: user.use_window_focus
-
focus <user.running_applications>: user.switcher_focus(running_applications)
```

Files that already had context constraints (like `app:` or `tag:`) use AND logic:

```talon
# Only active when: in terminal AND use_terminal is enabled
tag: terminal
and tag: user.use_terminal
-
lisa [dir] [<user.text>]: user.terminal_list_directories(text or "")
```

## Enabling Features

### Global (always on)

```talon
# my_globals.talon
-
tag(): user.use_alphabet
tag(): user.use_editing
tag(): user.use_window_focus
```

### Per-App

```talon
# my_vscode.talon
app: /vscode/i
-
tag(): user.use_languages
tag(): user.use_snippets
tag(): user.use_app_vscode
```

### Exclusion Pattern (everything except certain apps)

```talon
# my_defaults.talon
not app: /pianoteq/i
and not app: /vlc/i
and not app: /spotify/i
-
tag(): user.use_alphabet
tag(): user.use_numbers
tag(): user.use_editing
tag(): user.use_terminal
```

This gives you a "two-mode" setup: media/instrument apps get minimal commands, everything else gets your standard palette.

### Important: App-Specific Tag Chains

Some features depend on tags that apps assert. For example, `git.talon` requires:
```talon
tag: terminal
and tag: user.git
and tag: user.use_app_git
```

The `terminal` tag is asserted by terminal apps like iTerm or Apple Terminal. But those assertions are now gated too:

```talon
# apps/apple_terminal/apple_terminal.talon
app: apple_terminal
and tag: user.use_app_apple_terminal
-
tag(): terminal
```

So if you want git commands in Apple Terminal, you need BOTH:
```talon
app: /terminal/i
-
tag(): user.use_app_apple_terminal
tag(): user.use_app_git
```

## Available Tags

See `FEATURES.md` for the complete list, or `opt_in_template.talon` for a copy-paste starting point.

### Core (~45 tags)

| Tag | Description |
|-----|-------------|
| `use_alphabet` | Letter keys (air, bat, cap...) |
| `use_numbers` | Number input |
| `use_text_input` | Prose, formatters (say, snake, camel...) |
| `use_editing` | Copy, paste, undo, select... |
| `use_window_focus` | Focus app, snap window |
| `use_mouse` | Click, scroll, drag |
| `use_help` | Help commands |
| `use_terminal` | Terminal commands (requires terminal context) |
| `use_browser` | Browser commands (requires browser context) |
| `use_languages` | Programming language commands |
| `use_gamepad` | Gamepad/controller input |

### App-Specific (~68 tags)

Each app has its own tag: `use_app_chrome`, `use_app_vscode`, `use_app_iterm`, etc.

## Keeping Up With Upstream

```bash
cd ~/.talon/user/talon-community-opt-in

# Add upstream remote (once)
git remote add upstream https://github.com/talonhub/community.git

# Fetch and merge
git fetch upstream
git merge upstream/main

# Resolve conflicts (usually just keep both: upstream changes + your tag line)
# Then re-run guard scripts if new files were added
python3 scripts/add_feature_guards.py
python3 scripts/individualize_app_tags.py

git add -A
git commit -m "Merge upstream and re-apply guards"
```

## Suggested Learning Path

### Week 1: Basics
```talon
tag(): user.use_alphabet
tag(): user.use_window_focus
tag(): user.use_help
```

### Week 2: Editing
```talon
tag(): user.use_editing
tag(): user.use_symbols
```

### Week 3: Text & Dictation
```talon
tag(): user.use_text_input
```

### Week 4+: Add features as needed
Browse `FEATURES.md` and enable what you need for your workflow.

## Intentionally Ungated

These remain always-active:

- **Sleep/wake commands** — Must work to wake Talon up
- **Settings files** — No commands, just configuration

## Troubleshooting

### Commands not working?

1. **Check which command matched:** Say `talon test last` to see the filename and line number of the last matched command
2. **Check the tag is enabled:** Say "help tags" (requires `use_help`)
3. **Check for tag chain dependencies:** Look at the `.talon` file header to see what tags it requires (see "App-Specific Tag Chains" above)
4. **Use the REPL:** `events.tail()` shows actions being triggered

### Commands leaking through?

1. Make sure you don't have a backup of community repo in `~/.talon/user`
2. Check for `.talon` files without guards:
   ```bash
   grep -rL "user.use_" --include="*.talon" apps/ core/ plugin/ tags/ lang/
   ```

## Architecture Notes (for developers/Claude instances)

### Tag naming
- All opt-in tags use `user.use_*` prefix
- App-specific tags: `user.use_app_APPNAME`
- Defined in `core/feature_manager/feature_manager.py`

### Guard placement
- Files with no prior context: Add `tag: user.use_X` before `-`
- Files with existing context: Add `and tag: user.use_X` (AND logic, not OR)

### Context line logic
```talon
# These are OR'd (either activates the file):
tag: user.foo
tag: user.bar
-

# These are AND'd (both required):
tag: user.foo
and tag: user.bar
-
```

### Scripts
- `scripts/add_feature_guards.py` — Adds guards to unconstrained files
- `scripts/individualize_app_tags.py` — Creates per-app tags
- `scripts/diagnose_dependencies.py` — Shows what captures/lists each feature needs

