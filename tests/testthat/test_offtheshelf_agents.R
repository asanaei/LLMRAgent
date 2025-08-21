test_that("new_summarizer_agent constructs with summary memory and config", {
  skip_if_no_api()
  if (!requireNamespace("LLMR", quietly = TRUE)) {
    testthat::skip("LLMR not installed")
  }
  cfg <- LLMR::llm_config(provider = "openai", model = "gpt-4o-mini", api_key = "dummy")
  ag <- new_summarizer_agent(model_config = cfg)
  expect_s3_class(ag$memory, "environment")
  expect_true(inherits(ag$memory, "llmr_summary_memory"))
  expect_equal(ag$memory$model_config$model, "gpt-4o-mini")

  sum_cfg <- LLMR::llm_config(provider = "openai", model = "gpt-4o", api_key = "dummy")
  ag2 <- new_summarizer_agent(model_config = cfg, summarizer_model_config = sum_cfg)
  expect_equal(ag2$memory$model_config$model, "gpt-4o")
})
