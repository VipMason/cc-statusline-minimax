---
name: cc-statusline-minimax
description: Claude Code statusline showing MiniMax API quota usage, TPS, effort level, and context window utilization
---

# cc-statusline-minimax

A Claude Code statusline script that integrates with MiniMax API to display real-time quota usage, TPS metrics, and model information.

## What This Skill Does

Customizes your Claude Code statusline to show MiniMax API quota status with visual progress bars, helping you monitor usage limits and API performance.

## Features

- **Model Display** - Shows current AI model name
- **Effort Level** - Parsed from model name (high/mid/low)
- **Context Usage** - Context window utilization percentage
- **TPS Metrics** - Tokens per second throughput measurement (60s cache)
- **5h/7d Quota Bars** - Visual progress bars with percentage and time remaining
- **Coding Plan Quotas** - VLM and Search usage counters
- **Dynamic Colors** - Progress bars change color based on usage thresholds

## Configuration

Set in Claude Code `settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "C:/Users/YOUR_USERNAME/.claude/statusline-command.sh"
  }
}
```

**Auto-detection**: The script automatically finds `jq`, `mmx`, and `python` from PATH. No manual configuration needed if tools are installed.

## Output Format

```
[Model] | [effort] | ctx:X% | tps:X | ████░░░░░░ X% XhXm /5h | ████░░░░░░ X% XdXh /7d | v:X/150 s:X/100
```

## Color Coding

| Usage Level | Color |
|-------------|-------|
| < 50% | Green |
| 50-79% | Yellow |
| >= 80% | Red |

## Requirements

- mmx CLI (MiniMax API tool)
- jq for JSON parsing
- Python for TPS calculation
- Nerd Font for Unicode block characters

See full documentation at: https://github.com/VipMason/cc-statusline-minimax