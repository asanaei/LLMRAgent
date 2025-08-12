    
    test_that("create_message works", {
      m <- create_message("user","hi")
      expect_equal(m$role, "user")
      expect_equal(m$content, "hi")
      expect_s3_class(m, "llmr_agent_message")
    })

    test_that("format_messages_for_api strips extras", {
      msgs <- list(create_message("user","hi", name="bob"))
      out <- format_messages_for_api(msgs)
      expect_true(is.list(out[[1]]))
      expect_equal(out[[1]]$role, "user")
      expect_equal(out[[1]]$content, "hi")
    })
