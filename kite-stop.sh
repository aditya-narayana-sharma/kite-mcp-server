#!/usr/bin/env bash
# Stop the background Kite MCP server.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PID_FILE="$PROJECT_DIR/.kite-mcp-server.pid"

if [[ -f "$PID_FILE" ]]; then
  pid=$(cat "$PID_FILE")
  if kill -0 "$pid" 2>/dev/null; then
    kill "$pid"
    rm -f "$PID_FILE"
    echo "Stopped Kite MCP server (PID $pid)"
    exit 0
  fi
  rm -f "$PID_FILE"
fi

if lsof -nP -iTCP:8080 -sTCP:LISTEN >/dev/null 2>&1; then
  pkill -f "$PROJECT_DIR/kite-mcp-server" 2>/dev/null || true
  echo "Stopped kite-mcp-server on port 8080"
else
  echo "No Kite MCP server running on port 8080"
fi
