#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ ! -f .env ]]; then
  echo "Error: .env not found. Copy .env.example and add your Kite API credentials."
  exit 1
fi

if [[ ! -x ./kite-mcp-server ]]; then
  echo "Building kite-mcp-server..."
  go build -o kite-mcp-server main.go
fi

if lsof -nP -iTCP:8080 -sTCP:LISTEN >/dev/null 2>&1; then
  echo "Port 8080 is already in use. Stop the other process first:"
  lsof -nP -iTCP:8080 -sTCP:LISTEN
  exit 1
fi

set -a
source .env
set +a

export APP_MODE=http
export APP_HOST=localhost
export APP_PORT=8080

echo "Starting Kite MCP Server at http://localhost:8080/"
echo "MCP endpoint: http://localhost:8080/mcp"
echo "OAuth callback: http://localhost:8080/callback"
echo "Press Ctrl+C to stop."
exec ./kite-mcp-server
