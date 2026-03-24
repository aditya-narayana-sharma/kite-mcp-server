---
title: Tools
description: Complete reference for all MCP tools and their parameters
---

# Tools

Kite MCP exposes 23 tools. The AI assistant selects the appropriate tool based on the user's request. This page documents each tool and its parameters.

## Authentication

### login

Initiates the OAuth login flow. Returns a Kite login URL for the user to authenticate. If the user is already logged in, returns a confirmation with the username.

No parameters.

## Account

### get_profile

Returns user profile information including name, email, user ID, broker, and account type.

No parameters.

### get_margins

Returns available margins and funds across equity and commodity segments.

No parameters.

### get_holdings

Returns portfolio holdings from the user's demat account.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `type` | string | `full` | `full` returns detailed holdings with pagination. `summary` returns aggregated data. `compact` returns minimal fields with pagination. |
| `from` | number | 0 | Starting index for pagination (0-based). Applies to `full` and `compact` types. |
| `limit` | number | - | Maximum number of holdings to return. When specified, the response includes pagination metadata. Applies to `full` and `compact` types. |

### get_positions

Returns open intraday and overnight positions for the current day.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `from` | number | 0 | Starting index for pagination (0-based) |
| `limit` | number | - | Maximum number of positions to return |

## Orders

### get_orders

Returns all orders placed during the current trading day, including completed, cancelled, and rejected orders.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `from` | number | 0 | Starting index for pagination (0-based) |
| `limit` | number | - | Maximum number of orders to return |

### get_order_history

Returns the complete status trail for a specific order, showing every state transition from placement to completion.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `order_id` | string | yes | The order ID to look up |

### get_order_trades

Returns trades (fills) that resulted from a specific order.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `order_id` | string | yes | The order ID |

### get_trades

Returns all trades executed during the current trading day across all orders.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `from` | number | 0 | Starting index for pagination (0-based) |
| `limit` | number | - | Maximum number of trades to return |

### place_order

Places a new order on the exchange.

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `variety` | string | yes | `regular` | Order variety: `regular`, `co`, `amo`, `iceberg`, `auction` |
| `exchange` | string | yes | `NSE` | Exchange: `NSE`, `BSE`, `MCX`, `NFO`, `BFO` |
| `tradingsymbol` | string | yes | - | Trading symbol (e.g. `INFY`, `NIFTY2560118000CE`) |
| `transaction_type` | string | yes | - | `BUY` or `SELL` |
| `quantity` | number | yes | 1 | Number of shares or lots |
| `product` | string | yes | - | Product type: `CNC` (delivery), `MIS` (intraday), `NRML` (F&O overnight), `MTF` (margin funding) |
| `order_type` | string | yes | - | `MARKET`, `LIMIT`, `SL` (stop-loss limit), `SL-M` (stop-loss market) |
| `price` | number | no | - | Limit price. Required for `LIMIT` and `SL` orders. |
| `trigger_price` | number | no | - | Trigger price. Required for `SL` and `SL-M` orders. |
| `validity` | string | no | `DAY` | `DAY`, `IOC` (immediate or cancel), `TTL` (time-to-live in minutes) |
| `validity_ttl` | number | no | - | Order life span in minutes. Required when `validity` is `TTL`. |
| `disclosed_quantity` | number | no | - | Quantity disclosed to the market |
| `iceberg_legs` | number | no | - | Number of legs for iceberg orders |
| `iceberg_quantity` | number | no | - | Quantity per leg for iceberg orders |
| `tag` | string | no | - | Optional alphanumeric label for the order (max 20 characters) |
| `market_protection` | number | no | - | Market protection percentage for MARKET and SL-M orders. `0` disables, `1`-`100` sets a custom percentage, `-1` enables auto protection. |

### modify_order

Modifies an existing open order.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `variety` | string | yes | Order variety |
| `order_id` | string | yes | The order to modify |
| `order_type` | string | yes | New order type: `MARKET`, `LIMIT`, `SL`, `SL-M` |
| `quantity` | number | no | New quantity |
| `price` | number | no | New limit price |
| `trigger_price` | number | no | New trigger price |
| `validity` | string | no | New validity |
| `disclosed_quantity` | number | no | New disclosed quantity |

### cancel_order

Cancels an open order.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `variety` | string | yes | Order variety: `regular`, `co`, `amo`, `iceberg`, `auction` |
| `order_id` | string | yes | The order to cancel |

## GTT (Good Till Triggered)

GTT orders persist across trading sessions and execute automatically when a price condition is met.

### get_gtts

Returns all GTT orders.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `from` | number | 0 | Starting index for pagination (0-based) |
| `limit` | number | - | Maximum number of GTT orders to return |

### place_gtt_order

Creates a new GTT order. Supports single-leg triggers and two-leg OCO (one-cancels-other) triggers.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `exchange` | string | yes | `NSE`, `BSE`, `MCX`, `NFO`, `BFO` |
| `tradingsymbol` | string | yes | Trading symbol |
| `last_price` | number | yes | Current price of the instrument |
| `transaction_type` | string | yes | `BUY` or `SELL` |
| `product` | string | yes | `CNC`, `NRML`, `MIS`, `MTF` |
| `trigger_type` | string | yes | `single` or `two-leg` |

**Single-leg parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `trigger_value` | number | Price at which the order is triggered |
| `quantity` | number | Order quantity |
| `limit_price` | number | Limit price for the resulting order |

**Two-leg (OCO) parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `upper_trigger_value` | number | Upper trigger price |
| `upper_quantity` | number | Quantity for the upper leg |
| `upper_limit_price` | number | Limit price for the upper leg |
| `lower_trigger_value` | number | Lower trigger price |
| `lower_quantity` | number | Quantity for the lower leg |
| `lower_limit_price` | number | Limit price for the lower leg |

### modify_gtt_order

Modifies an existing GTT order. Accepts the same parameters as `place_gtt_order` plus `trigger_id`.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `trigger_id` | number | yes | ID of the GTT order to modify |

All other parameters from `place_gtt_order` are accepted.

### delete_gtt_order

Deletes a GTT order.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `trigger_id` | number | yes | ID of the GTT order to delete |

## Market Data

### get_quotes

Returns the complete market data snapshot for up to 500 instruments, including OHLC, volume, bid/ask market depth, and open interest.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `instruments` | string[] | yes | List of instruments in `exchange:tradingsymbol` format (e.g. `["NSE:INFY", "NSE:SBIN"]`) |

### get_ltp

Returns the last traded price for a list of instruments.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `instruments` | string[] | yes | List of instruments in `exchange:tradingsymbol` format |

### get_ohlc

Returns open, high, low, close prices for the current trading day.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `instruments` | string[] | yes | List of instruments in `exchange:tradingsymbol` format |

### get_historical_data

Returns historical OHLC candle data for an instrument.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `instrument_token` | number | yes | Numeric instrument token (use `search_instruments` to find this) |
| `interval` | string | yes | Candle interval: `minute`, `3minute`, `5minute`, `10minute`, `15minute`, `30minute`, `60minute`, `day` |
| `from_date` | string | yes | Start date in `YYYY-MM-DD HH:MM:SS` format |
| `to_date` | string | yes | End date in `YYYY-MM-DD HH:MM:SS` format |
| `continuous` | boolean | no | Stitch futures contracts into a continuous series |
| `oi` | boolean | no | Include open interest data |

### search_instruments

Searches the instrument master list across all exchanges. Supports multiple lookup modes.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `mode` | string | `search` | Lookup mode: `search`, `get_by_id`, `get_by_tradingsymbol`, `get_by_isin`, `get_by_inst_token`, `get_by_exch_token` |
| `verbosity` | string | `compact` | `compact` returns essential fields. `full` returns all instrument details. |
| `query` | string | - | Search text. Required for `search` mode. |
| `filter_on` | string | `id` | Field to search on: `id` (exchange:tradingsymbol), `name`, `isin`, `tradingsymbol`, `underlying` |
| `id` | string | - | Instrument ID in `EXCHANGE:TRADINGSYMBOL` format. Required for `get_by_id` mode. |
| `exchange` | string | - | Exchange code. Required for `get_by_tradingsymbol` and `get_by_exch_token` modes. |
| `tradingsymbol` | string | - | Trading symbol. Required for `get_by_tradingsymbol` mode. |
| `isin` | string | - | ISIN code. Required for `get_by_isin` mode. |
| `inst_token` | number | - | Instrument token. Required for `get_by_inst_token` mode. |
| `exch_token` | number | - | Exchange token. Required for `get_by_exch_token` mode. |

## Alerts

### alerts

Manages Kite price alerts. Supports creating, modifying, deleting, and retrieving alerts.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `mode` | string | yes | Operation: `get`, `create`, `modify`, `delete` |
| `uuids` | string[] | yes | Alert UUIDs. Pass an empty array for `get` mode to retrieve all alerts. Single UUID for `modify`. One or more for `delete`. |

**Additional parameters for `get` mode:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `status` | string | Filter by status: `enabled`, `disabled`, `deleted` |
| `type` | string | Filter by type: `simple`, `ato` |
| `history` | boolean | Include alert trigger history (default: `false`) |

**Additional parameters for `create` and `modify` modes:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | Alert name |
| `alert_type` | string | `simple` or `ato` (alert to order) |
| `lhs_exchange` | string | Exchange for the left-hand side instrument |
| `lhs_tradingsymbol` | string | Trading symbol for the left-hand side |
| `lhs_attribute` | string | Attribute to monitor (e.g. `LastTradedPrice`) |
| `operator` | string | Comparison operator: `<=`, `>=`, `<`, `>`, `==` |
| `rhs_type` | string | Right-hand side type: `constant` (fixed value) or `instrument` (another instrument's attribute) |
| `rhs_constant` | number | Target value. Required when `rhs_type` is `constant`. |
| `rhs_exchange` | string | Exchange for the RHS instrument. Required when `rhs_type` is `instrument`. |
| `rhs_tradingsymbol` | string | Trading symbol for the RHS instrument. Required when `rhs_type` is `instrument`. |
| `rhs_attribute` | string | Attribute for the RHS instrument. Required when `rhs_type` is `instrument`. |
| `basket` | string | JSON string with basket configuration for ATO alerts |

## Mutual Funds

### get_mf_holdings

Returns mutual fund holdings via Coin.

No parameters.
