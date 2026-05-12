# Claude Code MiniMax 状态栏

[English](./README.md) | [中文](./README_zh.md)

---

# Claude Code MiniMax 状态栏

一款定制的 Claude Code 状态栏，显示 MiniMax API 配额使用情况、TPS 指标等。

## 效果预览

```
[MiniMax-M2.7-highspeed] | [high] | ctx:45% | tps:128.5 | ████████░░ 78% 1h14m /5h | █████░░░░░ 52% 1d18h /7d | v:45/150 s:12/100
```

## 功能特性

- **模型名称** - 显示当前 AI 模型
- **Effort 级别** - 从模型名称解析 (high/mid/low)
- **上下文使用率** - 显示上下文窗口利用率
- **TPS (Tokens Per Second)** - 测量 API 吞吐量，缓存 60 秒
- **5h 配额进度条** - 每日用量，含进度条和剩余时间
- **7d 配额进度条** - 每周用量，含进度条和剩余时间
- **Coding plan 配额** - VLM 和 Search 使用计数
- **动态颜色** - 进度条颜色随用量变化：
  - 绿色：< 50%
  - 黄色：50-79%
  - 红色：>= 80%

## 环境要求

- [mmx](https://github.com/MiniMax-AI/cli) - MiniMax CLI 工具
- [jq](https://jqlang.github.io/jq/) - JSON 处理器
- Python（需能从 PATH 或完整路径访问 mmx）
- Git Bash / MINGW64 环境 (Windows)
- Nerd Font 字体以显示 Unicode 块字符（如 FiraCode Nerd Font）

## 安装步骤

### 1. 克隆或复制脚本

```bash
git clone https://github.com/YOUR_USERNAME/cc-statusline-minimax.git
```

### 2. 配置 Claude Code 设置

在 Claude Code 的 `settings.json` 中添加：

```json
{
  "statusLine": {
    "type": "command",
    "command": "C:/Users/YOUR_USERNAME/.claude/statusline-command.sh"
  }
}
```

### 3. 更新脚本中的路径

编辑 `statusline-command.sh`，根据你的系统更新以下路径：

```bash
JQ="/c/Users/YOUR_USERNAME/AppData/Roaming/TRAE SOLO CN/ModularData/ai-agent/vm/tools/app/jq/jq.exe"
MMX="/c/Users/YOUR_USERNAME/AppData/Roaming/npm/mmx"
PYTHON="/c/software/miniconda/python"
```

### 4. 安装依赖

**mmx:**
```bash
npm install -g @minimax-ai/mmx
mmx auth login --api-key YOUR_API_KEY
```

**jq:**
从 https://jqlang.github.io/jq/ 下载并添加到 PATH

### 5. (可选) 安装 Nerd Font

为正确显示 Unicode 块字符，请安装 [FiraCode Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases) 或其他 Nerd Font。

在 Windows Terminal 的 `settings.json` 中配置使用 FiraCode Nerd Font。

## 配置说明

### Effort 级别映射

从模型名称解析 effort 级别：
- `highspeed` 或 `high` → `high`
- `low` → `low`
- 其他 → `mid`

### 进度条颜色

| 使用量 | 颜色 |
|--------|------|
| < 50%  | 绿色 |
| 50-79% | 黄色 |
| >= 80% | 红色 |

### 配额显示

脚本显示 MiniMax-M* 主模型配额（5h 和 7d）以及 coding-plan 配额：
- `v` = coding-plan-vlm
- `s` = coding-plan-search

## 故障排查

### Unicode 字符乱码

请确保：
1. Windows Terminal 使用 Nerd Font（如 FiraCode）
2. Git Bash locale 设置为 UTF-8（`export LC_ALL=en_US.UTF-8`）

### mmx 找不到

在脚本顶部的变量中使用 `mmx.exe` 的完整路径。

### TPS 显示为 0

检查命令行中 `mmx text chat` 是否正常工作，以及 Python 能否解析 JSON 输出。

## 开源许可

MIT
