---
title: OAuth Flow
description: Authentication internals for self-hosted deployments
---

# OAuth Flow

This page documents the authentication internals for developers self-hosting Kite MCP Server. Users of the hosted service at `mcp.kite.trade` do not need this information.

## Overview

Kite MCP Server implements OAuth 2.1 with PKCE for authentication. The MCP client and server handle the entire flow. The user's only step is logging in on Zerodha's site when prompted.

```
MCP Client          Kite MCP Server         Zerodha
    │                     │                     │
    ├─ authorize ────────►│                     │
    │                     ├─ redirect ─────────►│
    │                     │                     │ (user logs in)
    │                     │◄─ auth code ────────┤
    │◄─ JWT token ────────┤                     │
```

1. The MCP client sends an authorization request with a PKCE challenge
2. The server redirects the user to Kite's login page
3. After successful login, Kite returns an authorization code to the server's callback endpoint
4. The server exchanges the code for a Kite access token, then issues a JWT to the MCP client
5. All subsequent tool calls use the JWT. Sessions last approximately 12 hours, matching Kite Connect's session duration.

## Session storage

The server holds a Kite access token in memory for the duration of each session. Nothing is persisted to disk. User credentials are never received or stored by the MCP server.

## OAuth endpoints

| Endpoint | Description |
|----------|-------------|
| `/.well-known/oauth-authorization-server` | Server metadata (RFC 8414) |
| `/.well-known/oauth-protected-resource` | Protected resource metadata |
| `/authorize` | Initiate OAuth flow |
| `/token` | Exchange authorization code for JWT |
| `/callback` | Receive Kite authorization code |
| `/register` | Dynamic client registration (RFC 7591) |

## Dynamic client registration

MCP clients such as `mcp-remote` register themselves automatically on first connection:

```
POST /register
Content-Type: application/json

{
  "client_name": "my-mcp-client",
  "redirect_uris": ["http://localhost:3000/callback"]
}
```

The server returns a `client_id` used for subsequent authorization requests.
