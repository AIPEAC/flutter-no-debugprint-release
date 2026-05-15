#!/usr/bin/env bash
# Install flutter-no-debugprint-release wrapper

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WRAPPER_DIR="$HOME/.flutter-ndrelease"

# Check if flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "Error: flutter not found in PATH. Please install Flutter first."
    exit 1
fi

# Create wrapper directory
mkdir -p "$WRAPPER_DIR"

# Copy wrapper
cp "$SCRIPT_DIR/bin/flutter" "$WRAPPER_DIR/flutter"
chmod +x "$WRAPPER_DIR/flutter"

# Detect shell and update appropriate rc file
SHELL_RC=""
if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$(basename "$SHELL")" == "zsh" ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ "$(basename "$SHELL")" == "bash" ]]; then
    SHELL_RC="$HOME/.bashrc"
else
    SHELL_RC="$HOME/.profile"
fi

# Add wrapper directory to PATH if not already present
if ! grep -q "$WRAPPER_DIR" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# flutter-no-debugprint-release wrapper" >> "$SHELL_RC"
    echo "export PATH=\"$WRAPPER_DIR:\$PATH\"" >> "$SHELL_RC"
    echo ""
    echo "Added wrapper to PATH in $SHELL_RC"
    echo "Please restart your terminal or run: source $SHELL_RC"
else
    echo "Wrapper directory already in PATH."
fi

echo ""
echo "Installation complete!"
echo ""
echo "Usage:"
echo "  flutter build <target> --ndrelease"
echo ""
echo "Examples:"
echo "  flutter build linux --ndrelease"
echo "  flutter build windows --ndrelease"
echo "  flutter build macos --ndrelease"
echo ""
