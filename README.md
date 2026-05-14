# Claude Code Statusline for MiniMax

[English](./README.md) | [中文](./README_zh.md)

---

A customized Claude Code statusline that displays MiniMax API quota usage, TPS metrics, and more.

## Preview

![Statusline Demo](statusline-demo.png)

```
[MiniMax-M2.7-highspeed] | [high] | ctx:45% | tps:128.5 | ████████░░ 78% 1h14m /5h | █████░░░░░ 52% 1d18h /7d | v:45/150 s:12/100
```

## Features

- **Model name** - Displays the current AI model
- **Effort level** - Parsed from model name (high/mid/low)
- **Context usage** - Shows context window utilization percentage
- **TPS (Tokens Per Second)** - Measures API throughput, cached for 60s
- **Dynamic quotas** - Automatically displays ALL quotas from your plan with progress bars
- **Dynamic colors** - Progress bars change color based on usage level:
  - Green: < 50%
  - Yellow: 50-79%
  - Red: >= 80%

## Requirements

- [mmx](https://github.com/MiniMax-AI/cli) - MiniMax CLI tool
- [jq](https://jqlang.github.io/jq/) - JSON processor
- Python with `mmx` accessible in PATH or via full path
- Git Bash / MINGW64 environment (Windows)
- **Nerd Font** — ⚠️ Required for Unicode block characters (`▓░`) to render correctly. Without it you'll see blank boxes.

## Installation

### One-Click Setup (Recommended)

```bash
curl -sL https://raw.githubusercontent.com/VipMason/cc-statusline-minimax/master/install.sh | bash
```

This will auto-detect and install missing dependencies (jq, mmx, python).

### Manual Setup

#### 1. Install dependencies

**mmx:**
```bash
npm install -g @minimax-ai/mmx
mmx auth login --api-key YOUR_API_KEY
```

**jq:**
```bash
# Windows (winget)
winget install jqlang.jq
# macOS
brew install jq
# Linux
sudo apt install jq
```

**python:** Download from https://www.python.org/downloads/

#### 2. Download script

```bash
curl -sL https://raw.githubusercontent.com/VipMason/cc-statusline-minimax/master/statusline-command.sh -o ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh
```

#### 3. Configure Claude Code

Add to your `settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline-command.sh"
  }
}
```

#### 4. (Optional) Install Nerd Font

For proper Unicode block character rendering, install [FiraCode Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases) (or any Nerd Font). Then configure your terminal to use it.

## Configuration

### Effort Level Mapping

The effort level is parsed from the model name:
- `highspeed` or `high` → `high`
- `low` → `low`
- otherwise → `mid`

### Progress Bar Colors

| Usage | Color |
|-------|-------|
| < 50%  | Green |
| 50-79% | Yellow |
| >= 80% | Red |

### Quota Display

The script shows MiniMax-M* main model quotas (5h and 7d) plus coding-plan quotas:
- `v` = coding-plan-vlm
- `s` = coding-plan-search

## Troubleshooting

### Garbled Unicode characters (blank boxes)

⚠️ Make sure your terminal uses a Nerd Font:
1. Install [FiraCode Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases)
2. Set it as your terminal's monospace font
3. On Windows, also set Git Bash locale: `export LC_ALL=en_US.UTF-8`

### mmx not found

Use full paths to `mmx.exe` in the script variables at the top.

### TPS shows 0

Check that `mmx text chat` works from command line and that Python can parse the JSON output.

## License

MIT
