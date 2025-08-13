test_that("build_context_message formats snippets", {
  msg <- build_context_message("What is X?", c("A", "B"))
  expect_true(grepl("Context:", msg, fixed = TRUE))
  expect_true(grepl("\n[S1] A", msg, fixed = TRUE))
  expect_true(grepl("\n[S2] B", msg, fixed = TRUE))
  expect_true(grepl("Question: What is X?", msg, fixed = TRUE))
})

test_that("build_classification_prompt lists labels", {
  msg <- build_classification_prompt("Great movie!", c("positive","negative"))
  expect_match(msg, "positive")
  expect_match(msg, "negative")
  expect_match(msg, "Return JSON")
})
