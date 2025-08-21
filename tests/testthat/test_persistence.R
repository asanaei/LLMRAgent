test_that("save_agent and load_agent round-trip basic state", {
  skip_if_no_api()
  skip_if_not_installed <- function(pkg) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      testthat::skip(paste("Package", pkg, "not installed"))
    }
  }
  skip_if_not_installed("LLMR")

  cfg <- LLMR::llm_config(provider = "openai", model = "gpt-4o-mini", api_key = "dummy")
  ag <- new_agent(system_prompt = "Be brief.", model_config = cfg, memory = new_buffer_memory(4))
  ag$memory$add(create_message("user", "hello"))
  ag$memory$add(create_message("assistant", "hi"))

  path <- tempfile(fileext = ".rds")
  save_agent(ag, path)
  expect_true(file.exists(path))

  ag2 <- load_agent(path)
  expect_equal(ag2$system_prompt, "Be brief.")
  expect_true(length(ag2$memory$get()) >= 2)
  # model_config should be preserved
  expect_equal(ag2$model_config$provider, "openai")
})

