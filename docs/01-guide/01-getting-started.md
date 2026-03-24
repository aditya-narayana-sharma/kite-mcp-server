---
title: Quick Start
description: Set up Kite MCP with your AI assistant
---

# Quick Start

## Prerequisites

- A Zerodha account with Kite
- [Node.js](https://nodejs.org/) (required for some clients)
- An MCP-compatible AI client

## Supported clients

Detailed setup instructions are available for each client:

- [[Claude Desktop]]
- [[Claude Code]]
- [[Cursor]]
- [[VS Code]]
- [[Windsurf]]
- [[Cline]]
- [[JetBrains]]
- [[Other Clients]]

## Server URL

All clients connect to the same endpoint:

```
https://mcp.kite.trade/mcp
```

Clients with native HTTP transport support (VS Code, Claude Code, Windsurf) can connect directly. Clients that use stdio transport (Claude Desktop, Cursor) require [mcp-remote](https://www.npmjs.com/package/mcp-remote) as a bridge.

## Authentication

On first use, the AI assistant will provide a login link. Open it in your browser to authenticate with your Zerodha credentials on Kite's login page. The AI client receives a temporary session token after authorization. Sessions last approximately 12 hours.

Your Zerodha credentials are never sent to the AI client or the MCP server. Authentication happens directly with Kite.
