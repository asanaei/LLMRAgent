    
    test_that("buffer memory keeps last n", {
      mem <- new_buffer_memory(2)
      mem$add(create_message("user","a"))
      mem$add(create_message("user","b"))
      mem$add(create_message("user","c"))
      expect_equal(length(mem$get()), 2)
    })

    test_that("agent_reply requires model_config", {
      expect_error(
        new_agent(system_prompt = "Be brief."),
        "model_config is required"
      )
    })
