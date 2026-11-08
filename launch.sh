#!/usr/bin/env bash
# ==============================================================================
# AetherCalc Pro - Universal Runner (Linux & Browser)
# ==============================================================================

set -e
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "=========================================================="
echo "   AETHERCALC PRO • Ultra Scientific & Analytical Engine  "
echo "=========================================================="
echo ""
echo "Select execution mode:"
echo "  1) Launch Native Linux Desktop App"
echo "  2) Launch Web App in Browser (Local Web Server)"
echo "  3) Open Standalone Portable HTML in default browser"
echo "  4) Rebuild All (Flutter Web & Linux)"
echo ""
read -p "Enter choice [1-4] (default: 1): " choice
choice=${choice:-1}

case "$choice" in
  1)
    echo "Starting native Linux desktop application..."
    if [ -f "$PROJECT_DIR/build/linux/x64/release/bundle/test" ]; then
      "$PROJECT_DIR/build/linux/x64/release/bundle/test"
    else
      export PATH="/home/vachaspati/development/flutter/bin:$PATH"
      flutter run -d linux
    fi
    ;;
  2)
    PORT=8080
    echo "Starting local web server for AetherCalc Pro at http://localhost:$PORT..."
    echo "Press Ctrl+C to stop."
    python3 -m http.server "$PORT" -d "$PROJECT_DIR/build/web"
    ;;
  3)
    echo "Opening standalone single-file PWA in browser..."
    xdg-open "$PROJECT_DIR/web_standalone/index.html" 2>/dev/null || sensible-browser "$PROJECT_DIR/web_standalone/index.html" 2>/dev/null || python3 -m webbrowser "$PROJECT_DIR/web_standalone/index.html"
    ;;
  4)
    export PATH="/home/vachaspati/development/flutter/bin:$PATH"
    echo "Rebuilding Web release..."
    flutter build web --release
    echo "Rebuilding Linux release..."
    flutter build linux --release
    echo "Builds complete!"
    ;;
  *)
    echo "Invalid option. Exiting."
    exit 1
    ;;
esac

