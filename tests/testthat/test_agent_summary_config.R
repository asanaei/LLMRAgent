test_that("new_agent wires summarizer config to summary memory by default", {
  skip_if_no_api()
  if (!requireNamespace("LLMR", quietly = TRUE)) {
    testthat::skip("LLMR not installed")
  }
  dummy_cfg <- LLMR::llm_config(provider = "openai", model = "gpt-4o-mini", api_key = "dummy")

  sm <- new_summary_memory()  # no config yet
  ag <- new_agent(system_prompt = "Be brief.", model_config = dummy_cfg, memory = sm)

  expect_true(!is.null(ag$memory$model_config))
  expect_equal(ag$memory$model_config$model, "gpt-4o-mini")

  other_cfg <- LLMR::llm_config(provider = "openai", model = "gpt-4o", api_key = "dummy")
  ag$set_summarizer_config(other_cfg)
  expect_equal(ag$memory$model_config$model, "gpt-4o")
})

test_that("new_agent respects explicit summarizer_model_config", {
  skip_if_no_api()
  if (!requireNamespace("LLMR", quietly = TRUE)) {
    testthat::skip("LLMR not installed")
  }
  base_cfg <- LLMR::llm_config(provider = "openai", model = "gpt-4o-mini", api_key = "dummy")
  sum_cfg  <- LLMR::llm_config(provider = "openai", model = "gpt-4o-long", api_key = "dummy")
  sm <- new_summary_memory()
  ag <- new_agent(system_prompt = "Be brief.", model_config = base_cfg, memory = sm,
                  summarizer_model_config = sum_cfg)
  expect_equal(ag$memory$model_config$model, "gpt-4o-long")
})
