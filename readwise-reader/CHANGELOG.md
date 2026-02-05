# Changelog

## 0.2.0

- Full-text search with BM25 scoring via DuckDB FTS extension (replaces ILIKE)
- Highlight-to-document ID reconciliation bridging Readwise Core v2 and Reader v3 APIs
- Three-tier doc ID resolution: v2_book_id lookup, URL match, prefixed fallback with deferred reconciliation
- Relaxed fact_highlights FK to support cross-API highlight ingestion
- FTS indexes auto-rebuild after sync operations
- Webhook handler integration tests (auth, document events, highlight events, error handling)
- Token refresh lifecycle tests (full OAuth flow, rotation invalidation, expired token handling)

## 0.1.0

- Initial project scaffold
- Readwise Reader API client with async httpx
- DuckDB storage layer (star schema)
- Batch sync engine (API -> DuckDB)
- MCP tools: documents, highlights, tags, search, library stats
- OAuth 2.1 authorization server with PKCE
- Streamable HTTP MCP server
- Cowork plugin: 5 commands, 3 skills
- Enrichment pipeline stubs
