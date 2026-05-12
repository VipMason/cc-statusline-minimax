#!/bin/bash
# jq and mmx paths for Windows Git Bash
# TODO: Update these paths for your system
JQ="/PATH/TO/jq.exe"
MMX="/PATH/TO/mmx"
PYTHON="/PATH/TO/python"

# ANSI colors
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

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

# Get MiniMax quota usage
QUOTA_JSON=$("$MMX" quota show --output json 2>/dev/null)

# Get MiniMax-M* quota (main model)
if [ -n "$QUOTA_JSON" ]; then
    USAGE_5H=$(echo "$QUOTA_JSON" | "$JQ" -r '.model_remains[] | select(.model_name | startswith("MiniMax-M")) | .current_interval_usage_count')
    TOTAL_5H=$(echo "$QUOTA_JSON" | "$JQ" -r '.model_remains[] | select(.model_name | startswith("MiniMax-M")) | .current_interval_total_count')
    REMAINS_5H=$(echo "$QUOTA_JSON" | "$JQ" -r '.model_remains[] | select(.model_name | startswith("MiniMax-M")) | .remains_time')
    USAGE_7D=$(echo "$QUOTA_JSON" | "$JQ" -r '.model_remains[] | select(.model_name | startswith("MiniMax-M")) | .current_weekly_usage_count')
    TOTAL_7D=$(echo "$QUOTA_JSON" | "$JQ" -r '.model_remains[] | select(.model_name | startswith("MiniMax-M")) | .current_weekly_total_count')
    REMAINS_7D=$(echo "$QUOTA_JSON" | "$JQ" -r '.model_remains[] | select(.model_name | startswith("MiniMax-M")) | .weekly_remains_time')

    if [ -n "$USAGE_5H" ] && [ -n "$TOTAL_5H" ] && [ "$TOTAL_5H" -gt 0 ]; then
        PCT_5H=$((USAGE_5H * 100 / TOTAL_5H))
    else
        PCT_5H=0
    fi

    if [ -n "$USAGE_7D" ] && [ -n "$TOTAL_7D" ] && [ "$TOTAL_7D" -gt 0 ]; then
        PCT_7D=$((USAGE_7D * 100 / TOTAL_7D))
    else
        PCT_7D=0
    fi

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

    TIME_5H=$(format_time $REMAINS_5H)
    TIME_7D=$(format_time $REMAINS_7D)

    # Get coding-plan quotas only
    QUOTAS=$(echo "$QUOTA_JSON" | "$JQ" -r '.model_remains[] | select(.model_name | startswith("coding-plan")) | "\(.model_name) \(.current_interval_usage_count)/\(.current_interval_total_count)"' 2>/dev/null)
else
    PCT_5H=0
    PCT_7D=0
    TIME_5H="--"
    TIME_7D="--"
    QUOTAS=""
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

# Build progress bar
build_bar() {
    local pct=$1
    local width=10
    local filled=$((pct * width / 100))
    [ $filled -gt $width ] && filled=$width
    local empty=$((width - filled))
    local bar=""
    local i
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

BAR_5H=$(build_bar $PCT_5H)
BAR_7D=$(build_bar $PCT_7D)
COLOR_5H=$(get_color $PCT_5H)
COLOR_7D=$(get_color $PCT_7D)

# Format quotas nicely
format_quotas() {
    local qs="$1"
    local result=""
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        name=$(echo "$line" | cut -d' ' -f1)
        usage=$(echo "$line" | cut -d' ' -f2)
        # Shorten names
        name=$(echo "$name" | sed 's/coding-plan-//g' | sed 's/vlm/v/g' | sed 's/search/s/g')
        result="${result}${YELLOW}${name}${RESET}:${CYAN}${usage}${RESET} "
    done <<< "$qs"
    echo "$result"
}

QUOTAS_FORMATTED=$(format_quotas "$QUOTAS")

# Output: [Model] | effort | ctx | tps | 5h bar | 7d bar | quotas
echo -e "${CYAN}[${MODEL}]${RESET} | ${GREEN}[${EFFORT}]${RESET} | ${YELLOW}ctx:${CTX_USAGE}%${RESET} | ${CYAN}tps:${TPS}${RESET} | ${COLOR_5H}${BAR_5H}${RESET} ${PCT_5H}% ${TIME_5H} /5h | ${COLOR_7D}${BAR_7D}${RESET} ${PCT_7D}% ${TIME_7D} /7d | ${QUOTAS_FORMATTED}"