---
title: MCP Tool Eval
---

# MCP Tool Evaluation

Evaluates how well LLMs select the right tools and parameters when interacting
with Kite MCP via natural language prompts.

## Architecture

```
eval/run.sh
├── go run ./cmd/mockserver  (mock Kite API + full MCP server)
│   └── mock_responses/      (kiteconnect-mocks data)
├── pi -ne -e npm:pi-mcp-adapter  (LLM agent with MCP tools)
│   └── eval/mcp.json        (points to mock server)
└── eval/prompts.jsonl       (test prompts + expected tool calls)
```

The mock server runs the **real MCP tool code** - same handlers, same schemas,
same validation. Only the Kite Connect API responses are mocked using the
official kiteconnect-mocks fixtures.

## Running

```bash
cd /path/to/kite-mcp-server

# Terminal 1: start mock server
go run ./cmd/mockserver

# Terminal 2: run eval
./eval/run.sh
```

Or all-in-one:

```bash
./eval/run.sh --start-server
```

## Prompt format

`eval/prompts.jsonl` - one JSON object per line:

```json
{"prompt": "What's the current price of Infosys?", "expected_tool": "market", "expected_mode": "ltp"}
{"prompt": "Buy 10 shares of INFY", "expected_tool": "orders", "expected_mode": "place"}
```

## How it works

1. Mock server starts with pre-seeded session and test JWT
2. pi connects via pi-mcp-adapter with directTools enabled (all 6 tools visible)
3. Each prompt is sent to pi with a system instruction to only make tool calls
4. The eval script captures which tool and mode pi selected
5. Results are compared against expected_tool/expected_mode
6. Summary printed with accuracy per tool and overall score
