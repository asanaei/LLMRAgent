test_that("new_agent requires model_config", {
  expect_error(new_agent(system_prompt = "Be brief."), "model_config is required")
})

test_that("new_agent works with valid config", {
  skip_if_no_api()
  
  if (requireNamespace("LLMR", quietly = TRUE)) {
    config <- LLMR::llm_config(
      provider = "openai",
      model = "gpt-4o-mini",
      api_key = Sys.getenv("OPENAI_API_KEY")
    )
    
    agent <- new_agent(
      system_prompt = "Be brief.",
      model_config = config
    )
    
    expect_equal(agent$model_config, config)
    expect_equal(agent$system_prompt, "Be brief.")
  }
})

test_that("agent with LLMR integration works", {
  skip_if_no_api()
  
  if (requireNamespace("LLMR", quietly = TRUE)) {
    config <- LLMR::llm_config(
      provider = "openai",
      model = "gpt-4o-mini",
      api_key = Sys.getenv("OPENAI_API_KEY"),
      temperature = 0.7,
      max_tokens = 50
    )
    
    agent <- new_agent(
      system_prompt = "You are a helpful assistant.",
      model_config = config
    )
    
    reply <- agent_reply(agent, "What is the capital of France? Answer in one word.", json = FALSE)
    expect_type(reply, "character")
    expect_true(nzchar(reply))
    expect_match(reply, "Paris", ignore.case = TRUE)
  }
})

test_that("agent memory works properly", {
  skip_if_no_api()
  
  if (requireNamespace("LLMR", quietly = TRUE)) {
    config <- LLMR::llm_config(
      provider = "openai",
      model = "gpt-4o-mini",
      api_key = Sys.getenv("OPENAI_API_KEY")
    )
    
    agent <- new_agent(
      system_prompt = "Remember our conversation. Be very brief.",
      model_config = config,
      memory = new_buffer_memory(3)
    )
    
    # First interaction
    reply1 <- agent_reply(agent, "My name is Alice")
    expect_type(reply1, "character")
    expect_true(nzchar(reply1))
    
    # Second interaction - memory should contain previous exchange
    reply2 <- agent_reply(agent, "What is my name?")
    expect_type(reply2, "character")
    expect_true(nzchar(reply2))
    
    # Check that memory contains messages
    memory_contents <- agent$memory$get()
    expect_gte(length(memory_contents), 2)  # At least some messages
  }
})