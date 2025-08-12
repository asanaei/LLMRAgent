LLMR.Agent 0.1.0
================

- Initial CRAN-ready release with conservative, deterministic core.
- Added optional `llm_adapter` to `new_agent()` with echo fallback.
- Implemented guarded tools via `register_basic_tools()`:
  - `web_search`, `wiki_fetch` fail clearly unless network explicitly enabled.
  - `execute_r` sandbox with CPU/elapsed limits and disabled dangerous functions.
- Memory: `new_buffer_memory()` and `new_summary_memory()` (stub with warning).
- Tests: deterministic unit tests with `testthat` (no network I/O).

