#!/bin/bash
# Claude Code Statusline for MiniMax
# Auto-detects required tools: jq, mmx, python
# Dynamically displays all available quotas from mmx

# ANSI colors
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

# Auto-detect tools
detect_tool() {
    local tool=$1
    local fallback=$2
    path_found=$(which "$tool" 2>/dev/null)
    if [ -n "$path_found" ] && [ -f "$path_found" ]; then
        echo "$path_found"
        return 0
    fi
    path_found=$(which "${tool}.exe" 2>/dev/null)
    if [ -n "$path_found" ] && [ -f "$path_found" ]; then
        echo "$path_found"
        return 0
    fi
    if [ -n "$fallback" ] && [ -f "$fallback" ]; then
        echo "$fallback"
        return 0
    fi
    return 1
}

JQ=$(detect_tool "jq" "")
MMX=$(detect_tool "mmx" "")
PYTHON=$(detect_tool "python3" "python")

if [ -z "$JQ" ] || [ ! -f "$JQ" ]; then
    echo -e "${RED}Error: jq not found. Install jq or add to PATH${RESET}" >&2
    exit 1
fi

if [ -z "$MMX" ] || [ ! -f "$MMX" ]; then
    echo -e "${RED}Error: mmx not found. Install mmx CLI first.${RESET}" >&2
    exit 1
fi

input=$(cat)

MODEL=$(echo "$input" | "$JQ" -r '.model.display_name')
CTX_USAGE=$(echo "$input" | "$JQ" -r '.context_window.used_percentage')

# Effort level
if echo "$MODEL" | grep -qi "highspeed\|high"; then
    EFFORT="high"
elif echo "$MODEL" | grep -qi "low"; then
    EFFORT="low"
else
    EFFORT="mid"
fi

# Get TPS - cache 60s
CACHE_FILE="/tmp/tps_cache_$$"
if [ ! -f "$CACHE_FILE" ] || [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0))) -gt 60 ]; then
    TPS=$("$PYTHON" -c "
import json, subprocess, time
try:
    t1 = time.time()
    r = subprocess.run('mmx text chat --model MiniMax-M2.7-highspeed --message \"hi\" --max-tokens 30 --output json', shell=True, capture_output=True, text=True, timeout=10)
    t2 = time.time()
    d = json.loads(r.stdout)
    ot = d.get('usage', {}).get('output_tokens', 0)
    if ot > 0:
        print(f'{ot/(t2-t1):.1f}')
    else:
        print('0')
except:
    print('0')
" 2>/dev/null)
    echo "$TPS" > "$CACHE_FILE"
else
    TPS=$(cat "$CACHE_FILE" 2>/dev/null || echo "0")
fi

# Get MiniMax quota usage
QUOTA_JSON=$("$MMX" quota show --output json 2>/dev/null)

# Build progress bar
build_bar() {
    local pct=$1
    local width=8
    [ $pct -gt 100 ] && pct=100
    local filled=$((pct * width / 100))
    [ $filled -gt $width ] && filled=$width
    local empty=$((width - filled))
    local bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done
    echo "$bar"
}

# Color logic for progress bars
get_color() {
    local pct=$1
    if [ "$pct" -lt 50 ]; then
        echo "$GREEN"
    elif [ "$pct" -lt 80 ]; then
        echo "$YELLOW"
    else
        echo "$RED"
    fi
}

# Format time remaining
format_time() {
    local ms=$1
    local s=$((ms / 1000))
    local m=$((s / 60))
    local h=$((m / 60))
    local d=$((h / 24))
    if [ $d -gt 0 ]; then
        echo "${d}d$((h % 24))h"
    else
        echo "$((m / 60))h$((m % 60))m"
    fi
}

# Shorten model name for display
shorten_name() {
    echo "$1" | sed \
        -e 's/^MiniMax-M[0-9]*\.[0-9]*-/M/g' \
        -e 's/-highspeed$//g' \
        -e 's/-low$//g' \
        -e 's/coding-plan-/cp-/g' \
        -e 's/vlm/v/g' \
        -e 's/search/s/g' \
        -e 's/text/t/g' \
        -e 's/image/i/g' \
        -e 's/video/vd/g' \
        -e 's/audio/a/g'
}

# Build dynamic quota display
QUOTA_OUTPUT=""
if [ -n "$QUOTA_JSON" ]; then
    # Get all model names
    MODEL_NAMES=$(echo "$QUOTA_JSON" | "$JQ" -r '.model_remains[].model_name' 2>/dev/null)

    while IFS= read -r name; do
        [ -z "$name" ] && continue

        # Skip if already processed (avoid duplicates)
        echo "$QUOTA_OUTPUT" | grep -qF "$name" && continue

        # Get quota data
        usage=$(echo "$QUOTA_JSON" | "$JQ" -r ".model_remains[] | select(.model_name == \"$name\") | .current_interval_usage_count")
        total=$(echo "$QUOTA_JSON" | "$JQ" -r ".model_remains[] | select(.model_name == \"$name\") | .current_interval_total_count")
        remains=$(echo "$QUOTA_JSON" | "$JQ" -r ".model_remains[] | select(.model_name == \"$name\") | .remains_time")

        # Calculate percentage
        if [ -n "$usage" ] && [ -n "$total" ] && [ "$total" -gt 0 ] 2>/dev/null; then
            pct=$((usage * 100 / total))
        else
            pct=0
        fi

        # Build display
        short=$(shorten_name "$name")
        bar=$(build_bar $pct)
        color=$(get_color $pct)
        time_str=$(format_time ${remains:-0})

        QUOTA_OUTPUT="${QUOTA_OUTPUT}${color}${short}:${bar}${RESET} ${pct}% ${time_str} "
    done <<< "$MODEL_NAMES"
fi

# Output: [Model] | effort | ctx | tps | quotas
echo -e "${CYAN}[${MODEL}]${RESET} | ${GREEN}[${EFFORT}]${RESET} | ${YELLOW}ctx:${CTX_USAGE}%${RESET} | ${CYAN}tps:${TPS}${RESET} | ${QUOTA_OUTPUT}"