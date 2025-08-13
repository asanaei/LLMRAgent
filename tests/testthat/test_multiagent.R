test_that("multi-agent orchestrator cycles and terminates by keyword", {
  # Build two minimal agents; we won't call LLMR in this test.
  mk_dummy_agent <- function() {
    e <- new.env(parent = emptyenv())
    e$system_prompt <- ""
    e$memory <- new_buffer_memory(2)
    e$model_config <- list()
    e
  }
  a1 <- mk_dummy_agent()
  a2 <- mk_dummy_agent()

  # Step function that returns a FINAL message on second turn
  counter <- 0L
  step_fn <- function(agent, input_text) {
    counter <<- counter + 1L
    if (counter >= 2L) return("[FINAL] done")
    paste("echo:", input_text)
  }

  orch <- new_multiagent_orchestrator(
    participants = list(
      list(role = "assistant", agent = a1),
      list(role = "critic", agent = a2)
    ),
    termination_fn = final_keyword_termination("[FINAL]"),
    max_turns = 5,
    step_fn = step_fn
  )

  tr <- orch$run("hello")
  # Expect at least 3 messages: user + two agent turns (second should be FINAL)
  expect_gte(length(tr), 3)
  last <- tr[[length(tr)]]
  expect_equal(last$role, "assistant")
  expect_true(grepl("\u005BFINAL\u005D", last$content, fixed = TRUE))
})

