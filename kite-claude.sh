#!/usr/bin/env bash
# Start Kite MCP server (all 22 tools) and open Claude Desktop.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

LOG_DIR="$PROJECT_DIR/.logs"
LOG_FILE="$LOG_DIR/kite-mcp-server.log"
PID_FILE="$PROJECT_DIR/.kite-mcp-server.pid"
CLAUDE_APP="/Applications/AI/Claude.app"
SERVER_URL="http://localhost:8080"
MCP_URL="$SERVER_URL/mcp"
CALLBACK_URL="$SERVER_URL/callback"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}✓${NC} $*"; }
warn()  { echo -e "${YELLOW}!${NC} $*"; }
fail()  { echo -e "${RED}✗${NC} $*" >&2; exit 1; }

server_running() {
  lsof -nP -iTCP:8080 -sTCP:LISTEN >/dev/null 2>&1
}

server_healthy() {
  curl -sf --max-time 3 "$SERVER_URL/" >/dev/null 2>&1
}

wait_for_server() {
  local tries=30
  while (( tries > 0 )); do
    if server_healthy; then
      return 0
    fi
    sleep 1
    ((tries--))
  done
  return 1
}

ensure_env() {
  [[ -f .env ]] || fail ".env missing. Copy .env.example and add Kite API credentials."
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
  [[ -n "${KITE_API_KEY:-}" && -n "${KITE_API_SECRET:-}" ]] || fail "KITE_API_KEY and KITE_API_SECRET must be set in .env"
}

ensure_binary() {
  if [[ ! -x ./kite-mcp-server ]]; then
    warn "Building kite-mcp-server..."
    command -v go >/dev/null 2>&1 || fail "Go is not installed. Run: brew install go"
    go build -o kite-mcp-server main.go
  fi
}

start_server() {
  mkdir -p "$LOG_DIR"

  if server_running; then
    if server_healthy; then
      info "Kite MCP server already running on port 8080"
      return 0
    fi
    fail "Port 8080 is in use but server is not healthy. Run: lsof -nP -iTCP:8080 -sTCP:LISTEN"
  fi

  info "Starting Kite MCP server (all tools enabled)..."
  nohup env \
    APP_MODE=http \
    APP_HOST=localhost \
    APP_PORT=8080 \
    EXCLUDED_TOOLS="${EXCLUDED_TOOLS:-}" \
    KITE_API_KEY="$KITE_API_KEY" \
    KITE_API_SECRET="$KITE_API_SECRET" \
    ./kite-mcp-server >>"$LOG_FILE" 2>&1 &

  echo $! >"$PID_FILE"
  info "Server PID $(cat "$PID_FILE") — logs: $LOG_FILE"

  wait_for_server || fail "Server did not become ready. Check $LOG_FILE"
  info "Server ready at $SERVER_URL"
}

verify_setup() {
  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$SERVER_URL/" || echo "000")
  [[ "$status" == "200" ]] || fail "Status page unreachable ($status)"

  if grep -q "registered=22" "$LOG_FILE" 2>/dev/null || grep -q "Tool registration complete" "$LOG_FILE" 2>/dev/null; then
    info "All 22 MCP tools registered (holdings, orders, GTT, market data, login)"
  else
    warn "Could not confirm tool count in logs yet — server may still be starting"
  fi

  [[ -f "$CLAUDE_APP/Contents/MacOS/Claude" ]] || fail "Claude Desktop not found at $CLAUDE_APP"

  if [[ ! -f "$HOME/Library/Application Support/Claude/claude_desktop_config.json" ]]; then
    warn "Claude MCP config not found — configure manually per README"
  else
    info "Claude MCP configured for $MCP_URL"
  fi
}

open_claude() {
  info "Opening Claude Desktop..."
  open -a "$CLAUDE_APP"
}

print_next_steps() {
  cat <<EOF

${GREEN}Ready.${NC} In Claude, start a new chat and say:

  ${YELLOW}Use the Kite login tool, then show my holdings.${NC}

First-time / new session:
  1. Claude runs ${YELLOW}login${NC} → click the Zerodha link (do NOT use get_token.py)
  2. Complete sign-in — browser must land on localhost with request_token in URL
  3. Kite app redirect URL (developers.kite.trade): ${YELLOW}http://localhost:8080/callback${NC}
     (http://localhost:8080 also works)
  4. Tell Claude: "I'm logged in" → ask for holdings, orders, etc.

Trading (place/modify/cancel orders, GTT) is enabled on this local server.

Stop server:  ${YELLOW}kite-stop${NC}
View logs:    tail -f "$LOG_FILE"

EOF
}

main() {
  echo "Kite MCP + Claude launcher"
  echo "=========================="
  ensure_env
  ensure_binary
  start_server
  verify_setup
  open_claude
  print_next_steps
}

main "$@"
