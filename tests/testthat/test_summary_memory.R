test_that("summary memory returns last user with warning", {
  sm <- new_summary_memory()
  sm$add(create_message("user", "first"))
  sm$add(create_message("assistant", "hi"))
  sm$add(create_message("user", "second"))
  expect_warning(txt <- sm$summary(), "not implemented")
  expect_equal(txt, "second")
})

