# Readwise Reader Plugin

Search, save, and surface your Readwise Reader library. Turn your read-it-later archive into an active knowledge base.

## Setup

1. Start the MCP server:
   ```
   cd readwise-reader
   uv run readwise-reader
   ```

2. The first connection triggers an OAuth flow that asks for your [Readwise API token](https://readwise.io/access_token).

3. Sync your library:
   ```
   /readwise-reader:search sync
   ```

## Commands

| Command | Description |
|---------|-------------|
| `/save <url>` | Save a URL to your Reader library |
| `/search <query>` | Search across documents, highlights, and notes |
| `/triage` | Process your Reader inbox |
| `/digest` | Get a reading activity summary |
| `/reference <topic>` | Surface saved knowledge on a topic |

## Skills

- **library-search** -- Query decomposition and search orchestration
- **content-triage** -- Inbox triage decision framework
- **knowledge-retrieval** -- Deep knowledge synthesis from highlights and annotations

## Architecture

The plugin connects to a local MCP server that:
- Proxies to the Readwise Reader API for live operations (save, update, delete)
- Syncs data to a local DuckDB database for fast search and analytics
- Uses OAuth 2.1 to securely manage the Readwise API token

## Requirements

- Python 3.13+
- A [Readwise](https://readwise.io) account with Reader access
- API token from [readwise.io/access_token](https://readwise.io/access_token)
