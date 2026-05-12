#!/bin/bash
# Claude Code Statusline for MiniMax - Installer
# Supports: Windows (Git Bash), Linux, macOS

set -e

CYAN='\033[0;36m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${CYAN}Claude Code Statusline for MiniMax Installer${RESET}"
echo ""

# Detect OS
OS_TYPE="unknown"
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OS_TYPE="windows"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
fi

echo -e "${YELLOW}Detected: $OS_TYPE${RESET}"
echo ""

# Check and install jq
check_jq() {
    if command -v jq &> /dev/null; then
        echo -e "${GREEN}✓ jq found${RESET}"
        return 0
    fi
    return 1
}

install_jq() {
    echo -e "${YELLOW}jq not found. Installing...${RESET}"

    if [[ "$OS_TYPE" == "windows" ]]; then
        # Try winget first
        if command -v winget &> /dev/null; then
            winget install jqlang.jq --accept-source-agreements --accept-package-agreements 2>/dev/null && echo -e "${GREEN}✓ jq installed via winget${RESET}" && return 0
        fi
        # Try choco
        if command -v choco &> /dev/null; then
            choco install jq -y 2>/dev/null && echo -e "${GREEN}✓ jq installed via choco${RESET}" && return 0
        fi
        # Manual download
        echo -e "${YELLOW}Downloading jq manually...${RESET}"
        curl -sL "https://github.com/jqlang/jq/releases/latest/download/jq-windows-amd64.exe" -o /tmp/jq.exe && \
        mkdir -p ~/.local/bin && \
        mv /tmp/jq.exe ~/.local/bin/jq.exe && \
        chmod +x ~/.local/bin/jq.exe && \
        export PATH="$HOME/.local/bin:$PATH" && \
        echo -e "${GREEN}✓ jq installed to ~/.local/bin/jq${RESET}" && return 0
    elif [[ "$OS_TYPE" == "linux" ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y jq 2>/dev/null && echo -e "${GREEN}✓ jq installed via apt${RESET}" && return 0
        elif command -v yum &> /dev/null; then
            sudo yum install -y jq 2>/dev/null && echo -e "${GREEN}✓ jq installed via yum${RESET}" && return 0
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y jq 2>/dev/null && echo -e "${GREEN}✓ jq installed via dnf${RESET}" && return 0
        fi
    elif [[ "$OS_TYPE" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            brew install jq 2>/dev/null && echo -e "${GREEN}✓ jq installed via brew${RESET}" && return 0
        fi
    fi

    echo -e "${RED}✗ Failed to install jq. Please install manually: https://jqlang.github.io/jq/${RESET}"
    return 1
}

# Check and install mmx
check_mmx() {
    if command -v mmx &> /dev/null; then
        echo -e "${GREEN}✓ mmx found${RESET}"
        return 0
    fi
    return 1
}

install_mmx() {
    echo -e "${YELLOW}mmx not found. Installing...${RESET}"

    if ! command -v npm &> /dev/null; then
        echo -e "${RED}✗ npm not found. Please install Node.js first: https://nodejs.org/${RESET}"
        return 1
    fi

    npm install -g @minimax-ai/mmx 2>/dev/null && echo -e "${GREEN}✓ mmx installed${RESET}" && return 0

    echo -e "${RED}✗ Failed to install mmx. Run manually: npm install -g @minimax-ai/mmx${RESET}"
    return 1
}

# Check and install python
check_python() {
    # Try python first (not python3 to avoid Windows Store stub)
    if command -v python &> /dev/null; then
        echo -e "${GREEN}✓ python found${RESET}"
        return 0
    fi
    if command -v python3 &> /dev/null; then
        echo -e "${GREEN}✓ python3 found${RESET}"
        return 0
    fi
    return 1
}

install_python() {
    echo -e "${YELLOW}python not found. Installing...${RESET}"

    if [[ "$OS_TYPE" == "windows" ]]; then
        if command -v winget &> /dev/null; then
            winget install Python.Python.3 --accept-source-agreements --accept-package-agreements 2>/dev/null && echo -e "${GREEN}✓ python installed via winget${RESET}" && return 0
        fi
        if command -v choco &> /dev/null; then
            choco install python -y 2>/dev/null && echo -e "${GREEN}✓ python installed via choco${RESET}" && return 0
        fi
        echo -e "${RED}✗ Failed to install python. Download: https://www.python.org/downloads/${RESET}"
        return 1
    elif [[ "$OS_TYPE" == "linux" ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y python3 2>/dev/null && echo -e "${GREEN}✓ python installed via apt${RESET}" && return 0
        fi
    elif [[ "$OS_TYPE" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            brew install python 2>/dev/null && echo -e "${GREEN}✓ python installed via brew${RESET}" && return 0
        fi
    fi

    echo -e "${RED}✗ Failed to install python. Download: https://www.python.org/downloads/${RESET}"
    return 1
}

# Install mmx auth
setup_mmx_auth() {
    echo ""
    echo -e "${YELLOW}Note: You need to authenticate with MiniMax:${RESET}"
    echo -e "  Run: ${CYAN}mmx auth login --api-key YOUR_API_KEY${RESET}"
    echo -e "  Get your API key: https://platform.minimaxi.com/"
}

# Main install flow
echo "=== Checking dependencies ==="

MISSING=0

if ! check_jq; then
    install_jq || MISSING=1
fi

if ! check_mmx; then
    install_mmx || MISSING=1
fi

if ! check_python; then
    install_python || MISSING=1
fi

if [[ $MISSING -eq 1 ]]; then
    echo ""
    echo -e "${RED}Some dependencies failed to install. Please install them manually and run this script again.${RESET}"
    exit 1
fi

echo ""
echo "=== Installing Claude Code statusline ==="

# Download script
SCRIPT_DIR="$HOME/.claude"
mkdir -p "$SCRIPT_DIR"

curl -sL "https://raw.githubusercontent.com/VipMason/cc-statusline-minimax/master/statusline-command.sh" -o "$SCRIPT_DIR/statusline-command.sh"
chmod +x "$SCRIPT_DIR/statusline-command.sh"

# Configure Claude Code settings
SETTINGS_FILE="$HOME/.claude/settings.json"
if [[ -f "$SETTINGS_FILE" ]]; then
    # Backup
    cp "$SETTINGS_FILE" "$SETTINGS_FILE.bak"
    # Add statusLine using jq
    if command -v jq &> /dev/null; then
        jq '.statusLine = {"type":"command","command":"'"$SCRIPT_DIR/statusline-command.sh"'"}' "$SETTINGS_FILE" > /tmp/settings_new.json && mv /tmp/settings_new.json "$SETTINGS_FILE"
        echo -e "${GREEN}✓ Claude Code settings updated${RESET}"
    else
        echo -e "${YELLOW}⚠ settings.json updated manually: add 'statusLine' section${RESET}"
    fi
else
    cat > "$SETTINGS_FILE" << EOF
{
  "statusLine": {
    "type": "command",
    "command": "$SCRIPT_DIR/statusline-command.sh"
  }
}
EOF
    echo -e "${GREEN}✓ Claude Code settings created${RESET}"
fi

echo ""
echo -e "${GREEN}=== Installation complete! ===${RESET}"
echo ""
setup_mmx_auth
echo ""
echo -e "Restart Claude Code to see the new statusline."