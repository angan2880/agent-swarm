#!/bin/bash
# Install agent-swarm to your system
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing agent-swarm..."

# Copy role definitions
mkdir -p ~/.local/share/swarm
cp "$SCRIPT_DIR"/roles/*.md ~/.local/share/swarm/
echo "  Roles → ~/.local/share/swarm/"

# Copy launcher
mkdir -p ~/.local/bin
cp "$SCRIPT_DIR"/bin/swarm ~/.local/bin/swarm
chmod +x ~/.local/bin/swarm
echo "  Launcher → ~/.local/bin/swarm"

# Check PATH
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo ""
    echo "  WARNING: ~/.local/bin is not in your PATH"
    echo "  Add this to your .zshrc:  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

echo ""
echo "Done. Run 'swarm' from any project directory."
