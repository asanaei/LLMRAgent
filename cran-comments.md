CRAN submission for LLMR.Agent 0.1.0
====================================

Summary
- Platform: macOS (local), R >= 4.2
- Checks run: `R CMD build`, `R CMD check --as-cran`, and `devtools::check()` (source of truth is base R CMD check)
- Result: 0 ERRORs / 0 WARNINGs. Only standard NOTEs appear (see below).

Notes
- Incoming feasibility: URLs may be reported as invalid when run offline (libcurl cannot resolve hosts). On CRAN, these resolve normally. The package does not access the network at build/check time.
- Future timestamps: macOS timing can trigger the “unable to verify current time” NOTE; not under our control.
- HTML manual validator: known spurious NOTEs about modern HTML elements (e.g., <main>) from tools::checkHTML; harmless and widely seen.
- Check dir detritus: “.DS_Store” can be present on macOS; ignored at build via .Rbuildignore; the NOTE is benign.

Network policy
- All examples, tests, and vignettes run without network access.
- Network tools (`web_search`, `wiki_fetch`) are registered but hard-fail with a clear error unless both
  `options(LLMR.Agent.enable_network = TRUE)` and `register_basic_tools(enable_network = TRUE)` are set.
- Examples for networked functionality are guarded and not executed by default.

Computation policy
- The `execute_r` tool is sandboxed: dangerous functions are disabled and CPU/elapsed timeouts are enforced.

Test policy
- Uses `testthat` (edition 3); all tests are deterministic and offline.

LLMR/OpenAI usage
- The optional adapter uses the `LLMR` package exclusively for API calls. Example configurations can use a cheap model such as `model = "gpt-4.1-nano"` with the key from `Sys.getenv("OPENAI_API_KEY")`. No network is used in CRAN examples/tests.

