# LLMRAgent – Developer Guide (single source of truth)

**Date:** 2025-08-12  
**Scope:** Deliver a conservative, expandable v0.1.0 agent framework in R.
**Philosophy:** "Better to omit a feature than ship a flaky one."

---

## 1) What exists now (in this zip)

- Package skeleton with R6 primitives (messages, tools, memory, agent).
- Minimal agent (`new_agent()`) with deterministic reply pathway; no auto-tools.
- Tool registry with conservative execution and explicit allow-list.
- Buffer memory.
- **Built-in tools are present but OFF by default** (opt-in registration required).
- Unit-test scaffolding (no network, no non-determinism).
- GitHub Actions workflow (commented instructions), pkgdown skeleton.
- Roxygen2 comments on all public functions/classes.

## 2) What is explicitly *not* included (by design)

- No network calls in examples/tests.  
- No dynamic tool-calling loop that parses model tool-calls.  
- No Python execution; no arbitrary `eval(parse())` without time limits.  
- No external model invocation; `LLMR::call_llm_robust` integration is left as an adapter stub.

## 3) How to use today

```r
# install deps you actually need
# install.packages(c("R6","tibble","purrr","jsonlite","glue"))

library(LLMRAgent)
agent <- new_agent(system_prompt = "Be brief.")
agent_reply(agent, "hello")
```

To enable built-in tools (still offline tests), opt-in registration at runtime:
```r
LLMRAgent::register_basic_tools(enable_network = FALSE)  # safe default
```

## 4) Detailed TODOs for the week (clear acceptance criteria)

### A. Core API hardening
- [ ] Finalize `Message` S3 with validators.  
  **Done when:** invalid role throws error; `format_messages_for_api()` strips non-API fields.
- [ ] `Tool` contract: parameters JSON Schema validation.  
  **Done when:** invalid args → informative `stop()`; includes `examples` tested offline.
- [ ] `ToolRegistry`: thread-safe (base R), idempotent add/remove.  
  **Done when:** duplicate names blocked; `list_tools()` shows tibble.
- [ ] Memory: add `SummaryMemory` stub + interface only (no LLM calls).  
  **Done when:** unit tests pass with `expect_warning()` for unimplemented methods.

### B. Agent behaviour
- [ ] `ConversableAgent` deterministic loop with **explicit** tool invocation API only.  
  **Done when:** user code must call `agent$use_tool("name", args)`; no auto-calls.
- [ ] Pluggable `llm_adapter` (function).  
  **Done when:** default returns a rule-based echo (deterministic); adapter can be swapped.

### C. Tools (opt-in)
- [ ] `web_search` via SerpAPI *or* duckdb cache (no default network).  
  **Done when:** requires explicit `enable_network=TRUE` and key; otherwise errors clearly.
- [ ] `wiki_fetch` using Wikipedia REST; same opt-in gating.  
  **Done when:** HTTP timeouts, user-agent set; errors surfaced.
- [ ] `execute_r` sandboxed with `setTimeLimit(2, 5)` and locked env.  
  **Done when:** infinite loops halted; `par()`/graphics disabled.
- [ ] Data tools (`lm_summary`, `run_t_test`) with `broom` if installed.  
  **Done when:** examples run offline deterministically.

### D. QA / CI / Docs
- [ ] 80%+ tests with `testthat`.  
  **Done when:** `R CMD check --as-cran` passes locally on macOS/Linux; GitHub Actions green.
- [ ] pkgdown basic site.  
  **Done when:** builds locally; deploy step commented until token set.
- [ ] Vignette "Conservative Agents 101" (no network).  
  **Done when:** all chunks `eval = FALSE` except pure R snippets.

### E. Backward-compatible extension points
- [ ] Keep exported helpers stable; document `lifecycle: experimental`.  
  **Done when:** NEWS.md states guarantees; new features behind options.

## 5) Design decisions (why)

- **No network in tests/examples** to satisfy CRAN policies on external resources and reproducibility.  
- **Adapters over inheritance** for LLM calls; tool I/O is plain lists → easy to extend.  
- **Functions + thin R6** to limit surface area and ease migration later.

## 6) Integration notes

- If integrating with an LLM, implement and inject `llm_adapter(messages, tools) -> list(text=..., tool_calls=...)`.
- Keep your adapter in a separate package/repo to avoid coupling.

## 7) How to enable/disable risky features

```r
options(LLMRAgent.autoload_tools = FALSE)        # default
options(LLMRAgent.enable_network = FALSE)        # default
options(LLMRAgent.execute_r.max_seconds = 2)     # CPU
options(LLMRAgent.execute_r.max_elapsed = 5)     # wall-clock
```

## 8) Release checklist
- [ ] Rev `DESCRIPTION`, tag v0.1.0.  
- [ ] Re-run `roxygen2::roxygenise()` and `devtools::check()` locally.  
- [ ] Ensure no examples/vignettes perform network I/O.

---

## Appendix – References
- CRAN Repository Policy (no writing outside temp, internet constraints).  
- Writing R Extensions (structure, NAMESPACE).  
- roxygen2 docs (Rd, NAMESPACE).  
- testthat docs (edition 3).  
- pkgdown basics.  
- `setTimeLimit()` to bound execution.

