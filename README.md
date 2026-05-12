# Claude Code Statusline for MiniMax

[English](./README.md) | [中文](./README_zh.md)

---

<!-- English -->

# Claude Code Statusline for MiniMax

A customized Claude Code statusline that displays MiniMax API quota usage, TPS metrics, and more.

## Preview

```
[MiniMax-M2.7-highspeed] | [high] | ctx:45% | tps:128.5 | ████████░░ 78% 1h14m /5h | █████░░░░░ 52% 1d18h /7d | v:45/150 s:12/100
```

## Features

- **Model name** - Displays the current AI model
- **Effort level** - Parsed from model name (high/mid/low)
- **Context usage** - Shows context window utilization percentage
- **TPS (Tokens Per Second)** - Measures API throughput, cached for 60s
- **5h quota bar** - Daily usage with progress bar and time remaining
- **7d quota bar** - Weekly usage with progress bar and time remaining
- **Coding plan quotas** - VLM and Search usage counts
- **Dynamic colors** - Progress bars change color based on usage level:
  - Green: < 50%
  - Yellow: 50-79%
  - Red: >= 80%

## Requirements

- [mmx](https://github.com/MiniMax-AI/cli) - MiniMax CLI tool
- [jq](https://jqlang.github.io/jq/) - JSON processor
- Python with `mmx` accessible in PATH or via full path
- Git Bash / MINGW64 environment (Windows)
- Nerd Font for Unicode block characters (e.g., FiraCode Nerd Font)

## Installation

### 1. Clone or copy the script

```bash
git clone https://github.com/YOUR_USERNAME/cc-statusline-minimax.git
```

### 2. Configure Claude Code settings

Add to your Claude Code `settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "C:/Users/YOUR_USERNAME/.claude/statusline-command.sh"
  }
}
```

### 3. Auto-detection (no manual config needed)

The script automatically detects `jq`, `mmx`, and `python` from your PATH. If a tool is not found, it shows an error message with installation instructions.

If auto-detection fails, you can set custom paths at the top of `statusline-command.sh`:
```bash
JQ="/custom/path/to/jq.exe"
MMX="/custom/path/to/mmx"
PYTHON="/custom/path/to/python"
```

### 4. Install dependencies

**mmx:**
```bash
npm install -g @minimax-ai/mmx
mmx auth login --api-key YOUR_API_KEY
```

**jq:**
Download from https://jqlang.github.io/jq/ and add to PATH

### 5. (Optional) Install Nerd Font

For proper Unicode block character rendering, install a Nerd Font like [FiraCode Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases).

Configure Windows Terminal to use FiraCode Nerd Font in `settings.json`.

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

### Garbled Unicode characters

Ensure:
1. Windows Terminal uses a Nerd Font (FiraCode, etc.)
2. Git Bash locale is set to UTF-8 (`export LC_ALL=en_US.UTF-8`)

### mmx not found

Use full paths to `mmx.exe` in the script variables at the top.

### TPS shows 0

Check that `mmx text chat` works from command line and that Python can parse the JSON output.

## License

MIT
