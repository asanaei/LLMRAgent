skip_if_no_key <- function(key_name = "OPENAI_API_KEY") {
  if (Sys.getenv(key_name) == "") {
    testthat::skip(paste("Environment variable", key_name, "not set"))
  }
}

test_that("summary memory errors without config", {
  sm <- new_summary_memory()
  sm$add(create_message("user", "first"))
  expect_error(sm$summary(), "model_config is required")
})

test_that("summary memory uses LLMR when config provided", {
  skip_on_cran()
  skip_if_no_key("OPENAI_API_KEY")
  if (requireNamespace("LLMR", quietly = TRUE)) {
    cfg <- LLMR::llm_config(provider = "openai", model = "gpt-4o-mini", api_key = Sys.getenv("OPENAI_API_KEY"))
    sm <- new_summary_memory()
    sm$add(create_message("user", "My name is Alice."))
    sm$add(create_message("assistant", "Nice to meet you."))
    sm$add(create_message("user", "Remember my name."))
    txt <- sm$summary(max_chars = 200, model_config = cfg)
    expect_type(txt, "character")
    expect_true(nzchar(txt))
    expect_lte(nchar(txt), 200)
  }
})
