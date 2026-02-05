# readwise-reader

last updated: 2026-02-05

MCP server + Cowork plugin for Readwise Reader. Search, save, triage, and surface your reading library from Claude.

## architecture

Three layers working together:

```
Cowork Plugin (commands/skills)
        |
   MCP Server (FastMCP, streamable HTTP)
   |         |          |
DuckDB    Readwise    OAuth 2.1
(local     API        (token bridge)
 cache)    (v2+v3)
```

- **MCP server** (`server.py`): Composite Starlette app hosting MCP tools, OAuth endpoints, and a webhook receiver on `https://localhost:8787` (TLS via mkcert)
- **Cowork plugin** (`plugin/readwise-reader/`): 5 commands + 3 skills that Claude uses to interact with the MCP server
- **OAuth server** (`auth/oauth_server.py`): Bridges Readwise API-key auth to MCP's JWT-based auth. Users enter their Readwise token once via an HTML form; MCP clients only ever see short-lived JWTs
- **DuckDB storage** (`storage/`): Star schema with `dim_documents`, `fact_highlights`, `staging_highlights`, `dim_tags`, `sync_state`, `audit_changes`. BM25 full-text search via the FTS extension
- **API client** (`api/client.py`): Async httpx client wrapping Reader v3 (documents, tags) and Core v2 (highlights, auth) with token bucket rate limiting

## quick start

```bash
# one-time: generate locally-trusted TLS certs
brew install mkcert
mkcert -install
mkdir -p certs && cd certs && mkcert localhost 127.0.0.1 ::1 && cd ..

# run
uv sync
uv run readwise-reader
```

First MCP connection triggers an OAuth flow prompting for your Readwise API token (get one at [readwise.io/access_token](https://readwise.io/access_token)). After that, sync your library:

```
/readwise-reader:search sync
```

## install in cowork

With the server running, install the plugin in Claude Desktop Cowork:

**Browse plugins > Add marketplace by URL**, then enter:
```
https://raw.githubusercontent.com/fblissjr/cowork-plugins/main/readwise-reader/marketplace.json
```

Or package and upload manually:
```bash
./scripts/package_plugin.sh    # creates readwise-reader.zip
```
Then **Browse plugins > Upload plugin** and drop the zip.

## MCP tools

| Tool | Description |
|------|-------------|
| `save_document` | Save a URL to Reader |
| `list_documents` | Query documents with filters (category, location, tag, since) |
| `get_document` | Get a single document by ID |
| `update_document` | Update document metadata (location, tags, title, notes) |
| `delete_document` | Delete a document |
| `search_library` | BM25 full-text search across documents |
| `search_highlights` | BM25 full-text search across highlights |
| `list_tags` | List all tags with usage counts |
| `get_documents_by_tag` | Get documents by tag |
| `get_inbox` | Get inbox items for triage |
| `triage_document` | Move a document to later/archive/delete |
| `batch_triage` | Triage multiple documents at once |
| `library_stats` | Get library statistics |
| `reading_digest` | Summarize recent reading activity |
| `sync_library` | Sync from Readwise API to local DuckDB |
| `get_highlights` | Get highlights, optionally by document |

## testing

```bash
uv run pytest tests/ -v
uv run ruff check src/ tests/
```

69 tests covering storage, API client, auth (including token refresh lifecycle), webhook handler, and MCP tools.

## data storage

DuckDB database at `~/.readwise-reader/reader.duckdb`. Encrypted token store at `~/.readwise-reader/tokens.enc` (Fernet symmetric encryption, key at `~/.readwise-reader/.key`).

## highlight reconciliation

Readwise has two APIs: Reader v3 (documents with UUID-style IDs) and Core v2 (highlights with integer `book_id`). When a highlight arrives before its parent document has synced, it goes to `staging_highlights` with a `v2:{book_id}` doc_id. After sync, `reconcile_orphaned_highlights()` moves resolved highlights to `fact_highlights` (which has a real FK to `dim_documents`).

## planned

- PyLate multi-vector embeddings for semantic search (model: `lightonai/GTE-ModernColBERT-v1`)
- Structured extraction pipeline (structure-it pattern)
